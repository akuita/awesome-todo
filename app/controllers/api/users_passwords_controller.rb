class Api::UsersPasswordsController < Api::BaseController
  def create    
    user = User.find_by(id: params[:user_id])
    unless user
      return base_render_record_not_found('User not found.')
    end
    
    if params[:password].blank?
      return render json: { message: I18n.t('activerecord.errors.messages.blank', attribute: 'Password') }, status: :unprocessable_entity
    end

    unless params[:password] == params[:password_confirmation]
      return render json: { message: I18n.t('devise.failure.invalid', authentication_keys: 'Password confirmation') }, status: :unprocessable_entity
    end

    user.password = User.encrypt_password(params[:password])
    if user.save
      render json: { status: 200, message: I18n.t('controller.password_created') }, status: :ok
    else
      error_response(user, user.errors.full_messages.join(', '))
    end
  end
end
