class DocumentsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def new
    @document = current_user.organization.documents.new
  end

  def create
    @document = current_user.organization.documents.new(document_params)
    if @document.save
      redirect_to documents_path, notice: "Document uploaded successfully"
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