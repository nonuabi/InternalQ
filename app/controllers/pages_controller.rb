# Public pages for Slack App Directory / marketplace requirements.
# No authentication required — used as Installation landing, Privacy policy, and Support URLs.
class PagesController < ApplicationController
  layout "application"

  def installation
    # Installation landing page: users who find the bot on Slack marketplace
    # can learn more and sign up to integrate the bot from our backoffice.
  end

  def privacy
    # Privacy policy URL (required by Slack and app marketplaces).
  end

  def support
    # Support URL — help center or support portal.
  end
end
