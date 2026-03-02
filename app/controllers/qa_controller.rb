class QaController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    question = params[:question].to_s.strip
    if question.blank?
      redirect_to ask_path, alert: "Question cannot be blank!"
      return
    end

    begin
      result = Qa::Answer.call(organization_id: current_user.organization_id, question: question)
      @question = question
      @answer = result[:answer]
      @sources = result[:sources]
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
