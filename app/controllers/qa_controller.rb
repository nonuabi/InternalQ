class QaController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def new
  end

  def create
    question = params[:question].to_s.strip
    if question.blank?
      redirect_to new_qa_path, alert: "Question cannot be blank"
      return
    end

    result = Qa::Answer.call(organization_id: current_user.organization_id, question: question)
    @question = question
    @answer = result[:answer]
    @sources = result[:sources]
    render :new
  end
end
