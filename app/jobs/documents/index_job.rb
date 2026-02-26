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
        embedding = Llm::OpenaiEmbeddings.embed(chunk)
        embedding_vector = "[#{embedding.join(",")}]"

        DocumentChunk.create!(
          organization: document.organization,
          document: document,
          chunk_index: index,
          content: chunk,
          embedding: embedding_vector,
          metadata: {
            title: document.title,
            file_name: document.file.filename.to_s
          }
        )
      end
    end

    document.update!(status: "indexed")
  rescue StandardError => e
    document.update!(status: "failed", error_message: e.message) if document.present?
    raise e
  end
end
