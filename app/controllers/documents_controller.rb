class DocumentsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def new
    @document = current_user.organization.documents.new
  end

  def create
  end
end