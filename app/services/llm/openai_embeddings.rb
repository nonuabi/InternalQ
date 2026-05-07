require "httparty"

module Llm
  class OpenaiEmbeddings
    include HTTParty
    base_uri "https://api.openai.com/v1"
    MODEL = "text-embedding-3-small"
    default_timeout 15

    def self.embed(text)
      resp = post(
        "/embeddings",
        headers: {
          "Authorization" => "Bearer #{ENV.fetch("OPENAI_API_KEY", nil)}",
          "Content-Type" => "application/json"
        },
        body: {
          input: text,
          model: MODEL
        }.to_json
      )
      raise resp.body unless resp.success?
      resp.parsed_response.dig("data", 0, "embedding")
    end
  end
end
