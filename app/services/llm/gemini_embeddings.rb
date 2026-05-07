require "httparty"

module Llm
  class GeminiEmbeddings
    include HTTParty
    # Use the stable v1 endpoint
    base_uri "https://generativelanguage.googleapis.com/v1"

    # Dedicated embedding model
    MODEL = "models/gemini-embedding-001"
    default_timeout 15

    def self.embed(text)
      api_key = ENV.fetch("GEMINI_API_KEY", nil)

      response = post(
        "/#{MODEL}:embedContent",
        headers: {
          "Content-Type" => "application/json",
          "x-goog-api-key" => api_key
        },
        body: {
          content: {
            parts: [ { text: text } ]
          }
        }.to_json
      )

      raise "Gemini Error: #{response.body}" unless response.success?

      # Accessing the vector values
      response.parsed_response.dig("embedding", "values")
    end
  end
end
