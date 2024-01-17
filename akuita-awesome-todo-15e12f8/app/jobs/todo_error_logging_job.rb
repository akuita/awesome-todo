
# typed: strict

class TodoErrorLoggingJob < ApplicationJob
  queue_as :default

  def perform(error_message, *args)
    Rails.logger.error("Todo creation error: #{error_message}, Additional Info: #{args.inspect}")
  end
end

class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked
end
