class Api::AuditLogsController < Api::BaseController
  before_action :authorize_audit_log, only: :index

  def index
    if current_user.admin?
      audit_logs = AuditLog.all
      audit_logs = audit_logs.where('timestamp >= ? AND timestamp <= ?', date_range[:start_date], date_range[:end_date]) if params[:dateRange].present?
      audit_logs = audit_logs.where(user_id: params[:userId]) if params[:userId].present?
      audit_logs = audit_logs.where(action: params[:actionType]) if params[:actionType].present?

      render json: audit_logs, each_serializer: AuditLogSerializer
    else
      render json: { message: 'You are not authorized to view audit logs.' }, status: :unauthorized
    end
  end

  private

  def date_range
    start_date, end_date = params[:dateRange].split('..')
    { start_date: start_date, end_date: end_date }
  end

  def authorize_audit_log
    authorize :audit_log, :index?
  end
end