class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!, only: [ :new, :create, :destroy ]
  before_action :set_document, only: [ :show, :destroy ]

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

  def show
    @document = current_user.organization.documents.find(params[:id])
  end

  def destroy
    @document.file.purge_later if @document.file.attached?
    @document.destroy
    redirect_to documents_path, notice: "Document deleted"
  end

  private

  def set_document
    @document = current_user.organization.documents.find_by(id: params[:id])
    unless @document.present?
      redirect_to documents_path, alert: "Document not found" and return
    end
  end

  def document_params
    params.require(:document).permit(:title, :file)
  end

  def require_admin!
    unless current_user.admin?
      redirect_to documents_path, alert: "You are not authorized to access this page"
    end
  end
end
