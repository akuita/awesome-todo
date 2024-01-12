
class Api::UsersPasswordsController < Api::BaseController
  before_action :validate_password_params, only: [:create]
  
  # New methods for password management tool integration
  def check_password_complexity
    render json: { complexity_compatible: current_resource_owner.password_complexity_compatible? }, status: :ok
  end

  def check_autofill_hints
    render json: { autofill_hints_compatible: current_resource_owner.autofill_hints_compatible? }, status: :ok
  end

  def create
    # Ensure compatibility with password management tools by supporting
    # standard protocols for password autofill and secure password suggestions
    response.set_header('X-Autofill', 'new-password')

    if current_resource_owner.valid_password?(params.dig(:old_password))
      # Use Devise's method for updating passwords
      if current_resource_owner.reset_password(params.dig(:new_password), params.dig(:password_confirmation))
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
    # Ensure the password and confirmation are present
    params.require(:new_password)
    params.require(:password_confirmation)
  end
end
