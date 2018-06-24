class BookNotifierMailer < ApplicationMailer

  def book_return_remind(book)
    @book = book
    @reservation = book.reservations.find_by(status: 'TAKEN')
    @borrower = @reservation.try(:user)

    return if @borrower.blank?

    mail(to: @borrower.email, subject: "Upływa termin zwrotu książki #{@book.title}")
  end

  def book_reserved_return(book)
    @book = book
    @reservation = book.reservations.find_by(status: 'TAKEN')
    @reserver = book.reservations.where(status: 'RESERVED').first.try(:user);

    return if @reserver.blank? || @reservation.blank?

    mail(to: @reserver.email, subject: "Upływa termin zwrotu książki #{@book.title}")
  end
end
