
# typed: strict

class TodoErrorLoggingJob < ApplicationJob
  queue_as :default

  def perform(error_message, attachment_info = nil, *args)
    error_details = attachment_info ? "Attachment Info: #{attachment_info.inspect}, " : ""
    Rails.logger.error("Todo creation error: #{error_message}, #{error_details}Additional Info: #{args.inspect}")
  end
end

class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked
end
