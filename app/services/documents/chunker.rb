module Documents
  class Chunker
    def self.call(text, chunk_size: 1000, overlap: 150)
      chunks = []
      i = 0

      while i < text.length
        chunks << text[i, chunk_size].to_s.strip
        i += chunk_size - overlap
      end

      chunks.reject(&:blank?)
    end
  end
end