class ReservationsHandler
  def initialize(user, book)
    @user = user
    @book = book
  end

  def can_reserve?
    book.can_reserve?(user)
  end

  def reserve
    return unless can_reserve?

    book.reservations.create(user: user, status: 'RESERVED')
  end

  def cancel_reservation
    book.reservations.where(user: user, status: 'RESERVED').order(created_at: :asc).first.update_attributes(status: 'CANCELED')
  end

  def can_take?
    not_taken? && ( available_for_users? || book.reservations.empty?)
  end

  def take
    return unless can_take?

    if available_reservation.present?
      perform_expiration_worker(available_reservation)
      available_reservation.update_attributes(status: 'TAKEN')
    else
      reservation = book.reservations.create(user: user, status: 'TAKEN')

      perform_expiration_worker(reservation)
      ReservationsMailer.confirmation(book, user).deliver_now
    end
  end

  def can_give_back?
    book.reservations.find_by(user: user, status: 'TAKEN').present?
  end

  def give_back
    return unless can_give_back?

    ActiveRecord::Base.transaction do
      book.reservations.find_by(status: 'TAKEN').update_attributes(status: 'RETURNED')
      next_in_queue.update_attributes(status: 'AVAILABLE') if next_in_queue.present?
    end
  end

  def not_taken?
    book.reservations.find_by(status: 'TAKEN').nil?
  end

  def available_for_users?
    if available_reservation.present?
      available_reservation.user == user
    else
      pending_reservations.nil?
    end
  end

  def available_reservation
    book.reservations.find_by(status: 'AVAILABLE')
  end

  def pending_reservations
    book.reservations.find_by(status: 'PENDING')
  end

  def next_in_queue
    book.reservations.where(status: 'RESERVED').order(created_at: :asc).first
  end

  private
  attr_reader :user, :book

  def perform_expiration_worker(reservation)
    ::BookReservationExpireWorker.perform_at(reservation.expires_at-1.day, reservation.book_id)
  end
end