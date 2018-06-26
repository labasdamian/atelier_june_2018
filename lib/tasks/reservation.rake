namespace :reservation do
  desc 'notifier'
  task book_return_remind: :environment do
    Reservation
      .includes(:book)
      .where(expires_at: Date.tomorrow.all_day)
      .each { |reservation| ::BookReservationExpireWorker.perform_async(reservation.book_id) }
  end
end
