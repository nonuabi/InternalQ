module Qa
  class Answer
    def self.call(user:, question:)
      q_embed = Llm::OpenaiEmbeddings.embed(question)
      chunks = Search::ChunkSearch.call(organization_id: user.organization_id, query_embedding: q_embed, limit: 8)

      return {
        answer: "I couldn't find that in the uploaded documents.",
        sources: []
      } if chunks.empty?

      sources_block = chunks.each_with_index.map do |chunk, index|
        "SOURCE #{index}: #{chunk.metadata["file_name"]} (chunk #{chunk.chunk_index})\n #{chunk.content}"
      end.join("\n\n")

      prompt = <<~PROMPT
        Answer ONLY using the sources below.
        If the answer is not present, say: "I couldn't find that in the uploaded documents."
        Return a short answer, then list SOURCE numbers used.

        QUESTION:
        #{question}

        SOURCES:
        #{sources_block}
      PROMPT

      answer_text = Llm::OpenaiChat.complete(prompt)
      sources = chunks.map.with_index do |chunk, index|
        {
          source: index,
          filename: chunk.metadata["file_name"],
          document_id: chunk.document_id,
          chunk_index: chunk.chunk_index
        }
      end

      { answer: answer_text, sources: sources }
    end
  end
end
