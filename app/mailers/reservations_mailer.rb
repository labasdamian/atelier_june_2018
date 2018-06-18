class ReservationsMailer < ApplicationMailer
  def confirmation(book, user)
    @book = book
    @user = user

    mail(to: user.email, subject: book.title)
  end
end