class ReservationsMailer < ApplicationMailer
  def confirmation(book, user)
    @book = book
    @user = user

    mail(to: user.email, subject: "Some super stuff")
  end
end