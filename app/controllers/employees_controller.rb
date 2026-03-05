class EmployeesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!, only: [ :make_admin ]

  def index
    @employees = User.where(organization_id: current_user.organization_id)
    @usage = Usage::LimitChecker.usage_for_display(organization_id: current_user.organization_id)
  end

  # admin making other user an admin too
  def make_admin
    @user = User.find_by(id: params[:id])
    unless @user.present?
      return redirect_to team_path, alert: "User not found!"
    end

    unless @user.organization_id == current_user.organization_id
      return redirect_to team_path, alert: "You can only change roles for users in your organization."
    end

    if @user.employee?
      @user.update!(role: "admin")
      redirect_to team_path, notice: "#{@user.email} is now an admin."
    else
      redirect_to team_path, alert: "That user is already an admin."
    end
  rescue StandardError => e
    redirect_to team_path, alert: "Failed to update role: #{e.message}"
  end
end
