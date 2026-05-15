class QaController < ApplicationController
  before_action :authenticate_user!

  def new
    @question = params[:question].to_s if params[:question].present?
  end

  def create
    question = params[:question].to_s.strip
    if question.blank?
      redirect_to ask_path, alert: "Question cannot be blank!"
      return
    end

    if question.length > 1_000
      redirect_to ask_path, alert: "Question is too long (max 1,000 characters)."
      return
    end

    unless Usage::LimitChecker.within_limit?(organization_id: current_user.organization_id)
      redirect_to ask_path, alert: "You've reached your monthly question limit. Please try again next month."
      return
    end

    begin
      result = Qa::Answer.call(organization_id: current_user.organization_id, question: question, source: "web")
      @question = question
      @answer = result[:answer]
      @sources = result[:sources]
      @show_slack_prompt = params[:onboarding] == "1"
      render :new
    rescue StandardError => e
      Rails.logger.error "QaController#create failed: #{e.message}"
      @question = question
      @answer = nil
      @sources = []
      flash.now[:alert] = "Sorry, something went wrong answering that. Please try again."
      render :new, status: :service_unavailable
    end
  end
end
