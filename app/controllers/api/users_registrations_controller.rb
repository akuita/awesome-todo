
class Api::UsersRegistrationsController < Api::BaseController
  def create
    @user = User.new(create_params)
    if @user.save
      if Rails.env.staging?
        # to show token in staging
        token = @user.respond_to?(:confirmation_token) ? @user.confirmation_token : ''
        render json: { message: I18n.t('common.200'), token: token }, status: :ok and return
      else
        head :ok, message: I18n.t('common.200') and return
      end
    else
      error_messages = @user.errors.messages
      render json: { error_messages: error_messages, message: I18n.t('email_login.registrations.failed_to_sign_up') },
             status: :unprocessable_entity
    end
  end

  def update
    user = User.find_by(id: params[:user_id])
    return render json: { message: I18n.t('common.404') }, status: :not_found unless user

    profile = user.profile
    profile.assign_attributes(profile_params)

    if profile.save
      render json: {
        status: 200,
        message: I18n.t('common.200'),
        profile: profile.as_json(only: [:id, :user_id, :profile_picture, :bio, :updated_at])
      }, status: :ok
    else
      render json: { message: profile.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def create_params
    params.require(:user).permit(:password, :password_confirmation, :email)
  end

  def profile_params
    params.permit(:profile_picture, :bio)
  end
end
