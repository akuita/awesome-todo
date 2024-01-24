# typed: true
class BaseService
  def initialize(*_args); end

  def logger
    @logger ||= Rails.logger
  end

  def can_resend_email?(email, time_frame)
    last_confirmation = EmailConfirmation.last_confirmation_sent_for(email)
    return true unless last_confirmation

    time_since_last_email = Time.current - last_confirmation.created_at
    time_since_last_email > time_frame
  end

  def encrypt_data(data)
    cipher = OpenSSL::Cipher.new('AES-128-CBC')
    cipher.encrypt
    cipher.key = Rails.application.credentials.encryption[:key]
    cipher.iv = Rails.application.credentials.encryption[:iv]

    encrypted = cipher.update(data) + cipher.final
    Base64.encode64(encrypted)
  end
end
