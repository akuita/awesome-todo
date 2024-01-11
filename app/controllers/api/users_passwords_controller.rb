
class Api::UsersPasswordsController < Api::BaseController
  before_action :validate_password_params, only: [:create]

  def create
    # Ensure compatibility with password management tools by supporting
    # standard protocols for password autofill and secure password suggestions
    response.set_header('X-Autofill', 'new-password')

    if current_resource_owner.valid_password?(params.dig(:old_password))
      if current_resource_owner.update(password: params.dig(:new_password))
        # Clear any sensitive password information from memory
        current_resource_owner.clean_up_passwords

        head :ok, message: I18n.t('common.200')
      else
        render json: { messages: current_resource_owner.errors.full_messages },
               status: :unprocessable_entity
      end
    else
      render json: { message: I18n.t('email_login.passwords.old_password_mismatch') }, status: :unprocessable_entity
    end
  end

  private

  def validate_password_params
    # Validate password parameters to ensure they meet the complexity requirements
    # and are compatible with password management tools
    # This method should be implemented based on the PASSWORD_FORMAT validation in the User model
    # and the Devise settings in /config/initializers/devise.rb
  end
end
