class Api::AuditLogsController < Api::BaseController
  before_action :admin_required

  def export
    date_range = params[:dateRange]
    start_date, end_date = date_range.split('..').map { |date| Date.parse(date) }
    audit_logs = AuditLog.where(timestamp: start_date.beginning_of_day..end_date.end_of_day)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ['ID', 'Action', 'Affected Resource', 'Timestamp', 'User IP', 'User ID']
      audit_logs.find_each do |log|
        csv << [log.id, log.action, log.affected_resource, log.timestamp, log.user_ip, log.user_id]
      end
    end

    temp_file = Tempfile.new(['audit_logs', '.csv'])
    temp_file.write(csv_data)
    temp_file.rewind

    AuditLogExportJob.perform_later(current_user.email, temp_file.path)

    render json: { message: 'Export initiated. You will receive an email with the download link.' }
  end
end