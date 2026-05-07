require "httparty"

module Llm
  class OpenaiChat
    include HTTParty
    base_uri "https://api.openai.com/v1"
    MODEL = "gpt-4o-mini"
    default_timeout 15

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
            { role: "system", content: "You are a strict RAG question-answering assistant. You MUST answer only using the information contained in the SOURCES provided in the user message. If the answer is not fully supported by the SOURCES, you MUST reply exactly: \"I couldn't find that in the uploaded documents.\" Do NOT answer any part of the question from your own knowledge or guess, even if it seems trivial (for example, math or general knowledge)." },
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
