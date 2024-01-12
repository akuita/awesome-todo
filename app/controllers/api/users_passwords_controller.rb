class Api::UsersPasswordsController < Api::BaseController
  before_action :validate_password_params, only: [:create]
  
  # Endpoint to check password complexity
  # @param none
  # @return [Boolean] complexity_compatible - Indicates if the password meets complexity requirements
  def check_password_complexity
    render json: { complexity_compatible: current_resource_owner.password_complexity_compatible? }, status: :ok
  end

  # Endpoint to check autofill hints compatibility
  # @param none
  # @return [Boolean] autofill_hints_compatible - Indicates if autofill hints are supported
  def check_autofill_hints
    render json: { autofill_hints_compatible: current_resource_owner.autofill_hints_compatible? }, status: :ok
  end
   
  # Endpoint to create or update a user's password
  # @param old_password [String] The current password of the user
  # @param new_password [String] The new password to be set for the user
  # @param password_confirmation [String] The confirmation for the new password
  # @return [void] Returns HTTP status code 200 if successful
  # @return [Hash] messages - The full error messages if the update fails
  # @return [Hash] message - The error message if the old password does not match
  def create
    # Ensure compatibility with password management tools by supporting
    # standard protocols for password autofill and secure password suggestions
    response.set_header('X-Autofill', 'new-password')

    if current_resource_owner.valid_password?(params.dig(:old_password))
      # Use Devise's method for updating passwords if password_confirmation is provided
      if params[:password_confirmation].present?
        if current_resource_owner.reset_password(params.dig(:new_password), params.dig(:password_confirmation))
          # Clear any sensitive password information from memory
          current_resource_owner.clean_up_passwords

          head :ok, message: I18n.t('common.200')
        else
          render json: { messages: current_resource_owner.errors.full_messages },
                 status: :unprocessable_entity
        end
      # Update password without confirmation if password_confirmation is not provided
      elsif current_resource_owner.update(password: params.dig(:new_password))
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
    # Ensure the password and confirmation are present if password_confirmation is provided
    if params[:password_confirmation].present?
      params.require(:new_password)
      params.require(:password_confirmation)
    end
    # Additional validation logic can be placed here if needed
  end
end
