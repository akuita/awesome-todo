class Api::UsersRegistrationsController < Api::BaseController
  def setup_profile
    user = User.find_by(id: params[:user_id], is_active: true)
    return base_render_record_not_found unless user

    profile = user.profile || user.build_profile
    profile.bio = params[:bio] if params[:bio].present?
    
    if params[:profile_picture].present?
      # Validate file type and bio length before processing
      validate_profile_picture(params[:profile_picture])
      validate_bio_length(params[:bio])
      
      # Upload logic here, assuming a service object handles the upload
      uploaded_path = ProfilePictureUploader.new(params[:profile_picture]).call
      profile.profile_picture = uploaded_path
    end

    if profile.save
      render json: { message: I18n.t('common.201'), profile: profile.as_json }, status: :created
    else
      base_render_unprocessable_entity(profile.errors.full_messages.join(', '))
    end
  end

  def create
    user = User.new(create_params)

    if user.save
      email_verification = user.build_email_verification
      email_verification.generate_verification_token

      if email_verification.save
        # Send verification email
        UserMailer.confirmation_instructions(user, email_verification.token).deliver_later

        render json: {
          status: 201,
          message: I18n.t('devise.registrations.signed_up_but_unconfirmed'),
          user: user.as_json(only: [:id, :username, :email, :created_at])
        }, status: :created
      else
        render json: { errors: email_verification.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    user = User.find_by(id: params[:user_id])
    return render json: { message: I18n.t('common.404') }, status: :not_found unless user

    profile = user.profile || user.build_profile
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

  def validate_profile_picture(file)
    raise Exceptions::InvalidFileTypeError, I18n.t('common.errors.invalid_file_type') unless file.image?
  end

  def validate_bio_length(bio)
    raise Exceptions::BioLengthLimitError, I18n.t('common.errors.bio_length_limit') if bio && bio.length > 500
  end

  def create_params
    # Merged the permitted parameters from both versions of the code
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  def profile_params
    params.permit(:profile_picture, :bio)
  end
end
