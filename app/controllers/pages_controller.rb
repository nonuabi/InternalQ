# Public pages for Slack App Directory / marketplace requirements.
# No authentication required — used as Installation landing, Privacy policy, and Support URLs.
class PagesController < ApplicationController
  layout "application"

  def installation
    # Send guests to sign up first; after sign up/log in they start the onboarding flow (Q&A page with upload CTA).
    if !user_signed_in?
      session["user_return_to"] = ask_path(onboarding: "1")
    end
  end

  def privacy
    # Privacy policy URL (required by Slack and app marketplaces).
  end

  def support
    # Support URL — help center or support portal.
  end

  def terms
    # Terms of service URL, referenced from Slack marketplace configuration.
  end
end
