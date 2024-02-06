# frozen_string_literal: true

module Api
  class ProjectsController < BaseController
    before_action :doorkeeper_authorize!

    def create
      project = Project.new(project_params.merge(user_id: current_resource_owner.id))

      if project.save
        render json: {
          status: I18n.t('common.201'),
          project: {
            id: project.id,
            name: project.name,
            user_id: project.user_id,
            created_at: project.created_at.iso8601
          }
        }, status: :created
      else
        render json: error_response(project, project.errors.full_messages.join(', ')), status: :unprocessable_entity
      end
    end

    private

    def project_params
      params.require(:project).permit(:name)
    end
  end
end
