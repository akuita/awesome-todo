class ApplicationController < ActionController::Base
  before_action :check_rate_limit, if: :user_signed_in?

  private

  def check_rate_limit
    key = "user:#{current_user.id}:email_confirmation_request"
    allowed_to_request = Rails.cache.fetch(key, expires_in: 2.minutes) { true }

    unless allowed_to_request
      render json: { error: I18n.t('errors.messages.rate_limit_exceeded') }, status: :too_many_requests
      return
    end

    Rails.cache.write(key, false, expires_in: 2.minutes)
  end

  def user_signed_in?
    current_user.present?
  end
end
