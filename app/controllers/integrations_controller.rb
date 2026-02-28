class IntegrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @integrations = current_user.organization.integrations
    @slack_integration = @integrations.find { |i| i.provider == "slack" }
  end
end
