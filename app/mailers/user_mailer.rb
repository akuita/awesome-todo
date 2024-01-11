
class UserMailer < ApplicationMailer
  default from: 'no-reply@example.com'

  def confirmation_email(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: 'Confirm your email address')
  end

  def resend_confirmation_instructions(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: 'Resend confirmation instructions')
  end
end
