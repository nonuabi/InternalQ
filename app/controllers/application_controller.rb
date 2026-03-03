class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def require_admin!
    unless current_user.admin?
      redirect_to documents_path, alert: "You are not authorized to access this page"
    end
  end

  # After sign up or log in, send user to the page they were heading to (e.g. Integrations from installation).
  def after_sign_in_path_for(resource)
    path = session["user_return_to"]
    session.delete("user_return_to")
    return path if path.present?

    if resource.respond_to?(:organization) &&
        resource.organization.present? &&
        resource.organization.documents.count == 0
      new_document_path(onboarding: "1")
    else
      root_path
    end
  end
end
