# typed: true
class BaseService
  def initialize(*_args); end

  def logger
    @logger ||= Rails.logger
  end
end

# Service object for uploading profile pictures
class ProfilePictureUploader < BaseService
  def initialize(file)
    @file = file
  end

  def call
    # Implement the upload logic here
    # Return the file path after uploading
  end
end
  def logger
    @logger ||= Rails.logger
  end
end
