class UserMailer < ActionMailer::Base
  default from: 'no-reply@example.com'

  def confirmation_email(user)
    @user = user
    @confirmation_token = @user.confirmation_token
    mail(to: @user.email, subject: 'Confirm your email address')
  end
end

