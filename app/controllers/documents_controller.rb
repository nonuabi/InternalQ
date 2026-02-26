class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!, 

  def index
    @documents = current_user.organization.documents.order(created_at: :desc)
  end

  def new
    @document = current_user.organization.documents.new
  end

  def create
    @document = current_user.organization.documents.new(document_params)
    @document.status = "uploaded"
    
    if @document.save
      Documents::IndexJob.perform_later(@document.id)
      redirect_to documents_path, notice: "Uploaded! Indexing started in background..."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def document_params
    params.require(:document).permit(:title, :file)
  end

  def require_admin!
    unless current_user.admin?
      redirect_to documents_path, alert: "You are not authorized to access this page"
    end
  end
end