class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env["omniauth.auth"]
    @user = User.from_google(auth)

    if @user.persisted?
      flash[:notice] = I18n.t("devise.omniauth_callbacks.success", kind: "Google")
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.google_data"] = auth.except("extra")
      redirect_to new_user_registration_url, alert: "There was a problem signing in with Google. Please try again or use email and password."
    end
  rescue StandardError => e
    Rails.logger.error("Google OAuth error: #{e.class} - #{e.message}")
    redirect_to new_user_session_path, alert: "Something went wrong while signing in with Google. Please try again."
  end

  def failure
    redirect_to new_user_session_path, alert: "Google sign in was cancelled or failed. Please try again."
  end
end

