class Documents::IndexJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    document = Document.find(document_id)
    document.update!(status: "processing")

    text = Documents::TextExtractor.call(document)
    document.update!(extracted_text: text)

    chunks = Documents::Chunker.call(text)

    DocumentChunk.transaction do
      document.document_chunks.destroy_all

      chunks.each_with_index do |chunk, index|
        embedding = LLM::OpenAIEmbeddings.embed(chunk)

        DocumentChunk.create!(
          organization: document.organization,
          document: document,
          chunk_index: index,
          content: chunk,
          embedding: embedding,
          metadata: {
            title: document.title,
            file_name: document.file.filename
          }
        )
      end
    end

    document.update!(status: "indexed")
  rescue StandardError => e
    document.update!(status: "failed", error_message: e.message)
    raise e
  end
end
