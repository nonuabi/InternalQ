class QaController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    question = params[:question].to_s.strip
    if question.blank?
      redirect_to new_qa_path, alert: "Question cannot be blank"
      return
    end

    result = Qa::Answer.call(user: current_user, question: question)
    @question = question
    @answer = result[:answer]
    @sources = result[:sources]
    render :new
  end
end
