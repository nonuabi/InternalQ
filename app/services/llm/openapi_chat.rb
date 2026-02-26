module LLM
  class OpenAIChat
    include httparty
    base_uri "https://api.openai.com/v1"
    MODEL = "gpt-4o-mini"

    def self.complete(prompt)
      resp = post(
        "/chat/completions",
        headers: {
          "Authorization" => "Bearer #{ENV.fetch("OPENAI_API_KEY", nil)}",
          "Content-Type" => "application/json"
        },
        body: {
          model: MODEL,
          messages: [
            { role: "system", content: "You are a helpful company policy assistant." },
            { role: "user", content: prompt }
          ],
          temperature: 0.2
        }.to_json
      )
      raise resp.body unless resp.success?
      resp.parsed_response.dig("choices", 0, "message", "content").to_s
    end
  end
end
