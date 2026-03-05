module Qa
  class Answer
    FALLBACK_ANSWER = "I couldn't find that in the uploaded documents.".freeze

    def self.call(organization_id:, question:, source: "web")
      # Record usage for this question (counts toward monthly limit; we call embeddings + possibly chat).
      Usage::Recorder.record(organization_id: organization_id, source: source)

      # Keep question length reasonable for embeddings / LLM prompt.
      question = question.to_s.strip
      question = question[0, 2_000] if question.length > 2_000

      q_embed = Llm::OpenaiEmbeddings.embed(question)
      chunks = Search::ChunkSearch.call(organization_id: organization_id, query_embedding: q_embed, limit: 8)

      if chunks.empty?
        log_unanswered(organization_id: organization_id, question: question)
        return {
          answer: FALLBACK_ANSWER,
          sources: []
        }
      end

      sources_block = chunks.each_with_index.map do |chunk, index|
        "SOURCE #{index}: #{chunk.metadata["file_name"]} (chunk #{chunk.chunk_index})\n #{chunk.content}"
      end.join("\n\n")

      prompt = <<~PROMPT
        Answer ONLY using the sources below.
        If the answer is not present, say: "I couldn't find that in the uploaded documents."
        Return a short answer. Do not mention or list source numbers in the answer.

        QUESTION:
        #{question}

        SOURCES:
        #{sources_block}
      PROMPT

      answer_text = Llm::OpenaiChat.complete(prompt)

      if answer_text.to_s.strip == FALLBACK_ANSWER
        log_unanswered(organization_id: organization_id, question: question)
      end

      { answer: answer_text }
    end

    def self.log_unanswered(organization_id:, question:)
      UnansweredQuestion.create!(
        organization_id: organization_id,
        question: question
      )
    rescue StandardError => e
      Rails.logger.error "Failed to log unanswered question: #{e.message}"
    end
  end
end
