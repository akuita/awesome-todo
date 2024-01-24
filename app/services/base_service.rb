# typed: true
class BaseService
  def initialize(*_args); end

  def logger
    @logger ||= Rails.logger
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
