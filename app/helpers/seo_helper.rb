module SeoHelper
  DEFAULT_META_DESC = "InternalQ lets your team ask questions about internal documents directly in Slack. Upload handbooks, policies and SOPs - get instant AI-powered answers."
  DEFAULT_TITLE     = "InternalQ - AI knowledge assistant for Slack teams"
  DEFAULT_CANONICAL = "https://internalq.zezlab.com"
  DEFAULT_OG_IMAGE  = "https://internalq.zezlab.com/icon.png"

  def seo_title
    content_for(:title).presence || DEFAULT_TITLE
  end

  def seo_description
    content_for(:meta_description).presence || DEFAULT_META_DESC
  end

  def seo_canonical
    content_for(:canonical_url).presence || DEFAULT_CANONICAL
  end
end
