# frozen_string_literal: true

module OauthTokensConcern
  extend ActiveSupport::Concern

  def current_resource_owner
    doorkeeper_token&.resource_owner
  end
  alias current_user current_resource_owner
end
