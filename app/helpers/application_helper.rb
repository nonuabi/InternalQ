module ApplicationHelper
  LP_ACTIVE_LINK_STYLE = "color:#0b0f0e;font-weight:500".freeze

  def lp_landing_link(label, url = nil, active: false)
    if active
      tag.span(label, style: LP_ACTIVE_LINK_STYLE)
    else
      link_to(label, url)
    end
  end
end
