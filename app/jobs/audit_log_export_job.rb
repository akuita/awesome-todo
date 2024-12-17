class AuditLogExportJob < ApplicationJob
  queue_as :default

  def perform(user_email, csv_file_path)
    # Here you would implement the logic to send the email with the download link.
    # This is a placeholder example using ActionMailer, which you would need to configure.
    AuditLogMailer.with(user_email: user_email, csv_file_path: csv_file_path).export_email.deliver_later
  end
end