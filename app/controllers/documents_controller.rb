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
      if params[:onboarding] == "1"
        doc_title = @document.title.presence || "this document"
        redirect_to ask_path(
          question: "Summarize the key points from #{doc_title}",
          onboarding: "1"
        ), notice: "Uploaded! We’re indexing your document. Ask a question while we finish up."
      else
        redirect_to documents_path, notice: "Uploaded! Indexing started in background..."
      end
    else
      render :new, status: :unprocessable_entity
    end
  rescue StandardError => e
    redirect_to new_document_path, alert: "Failed to upload document: #{e.message}"
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
end
