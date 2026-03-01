require "pdf/reader"
require "docx"

module Documents
  class TextExtractor
    def self.call(document)
      blob = document.file.blob
      extension = blob.filename.extension_with_delimiter.downcase

      tempfile = Tempfile.new([ "doc", ".#{extension}" ])
      tempfile.binmode
      tempfile.write(blob.download)
      tempfile.rewind

      text = case extension
      when ".pdf"
          extract_text_from_pdf(tempfile)
      when ".docx"
          extract_text_from_docx(tempfile)
      else
          raise "Unsupported file type: #{extension}"
      end

      text.gsub(/\u0000/, "")
    ensure
      tempfile&.close!
    end

    private

    def self.extract_text_from_pdf(tempfile)
      reader = PDF::Reader.new(tempfile)
      reader.pages.map(&:text).join("\n")
    end

    def self.extract_text_from_docx(tempfile)
      doc = Docx::Document.open(tempfile)
      doc.paragraphs.map(&:text).join("\n")
    end
  end
end
