class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @organization = current_user.organization
    return unless @organization

    @usage = Usage::LimitChecker.usage_for_display(organization_id: @organization.id)
    @documents_count = @organization.documents.count
    @slack_connected = @organization.integrations.exists?(provider: "slack")
    @unanswered_count = @organization.unanswered_questions.where("created_at >= ?", 30.days.ago).count
    @recent_documents = @organization.documents.order(updated_at: :desc).limit(5)
    @recent_unanswered = @organization.unanswered_questions.order(created_at: :desc).limit(5) if current_user.admin?
  end
end
