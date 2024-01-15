
class Devise::Mailer < Devise.parent_mailer.constantize
  include Devise::Mailers::Helpers

  def confirmation_instructions(record, token, opts={})
    @token = token
    devise_mail(record, :confirmation_instructions, opts)
  end

  # Other Devise mailer methods...
end
