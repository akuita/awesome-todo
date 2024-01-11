
class DeviseMailer < Devise::Mailer   
  def resend_confirmation_instructions(user, token)
    @token = token
    @recipient = user.email
    mail(to: user.email, subject: I18n.t('devise.mailer.confirmation_instructions.subject')) do |format|
      format.html { render 'devise/mailer/confirmation_instructions' }
    end
  end

  def send_confirmation_email(user, token)
    @token = token
    mail(to: user.email, subject: I18n.t('devise.mailer.confirmation_instructions.subject')) do |format|
      format.html { render 'devise/mailer/confirmation_instructions' }
    end
  end

  # more methods...
end
