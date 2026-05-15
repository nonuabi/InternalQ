class Document < ApplicationRecord
  belongs_to :organization
  has_many :document_chunks, dependent: :destroy

  has_one_attached :file

  validates :status, presence: true
  validates :file, presence: true
  validates :title, presence: true, length: { maximum: 80 }

  validate :file_size_under_limit
  validate :file_content_type_allowed

  private

  def file_size_under_limit
    return unless file.attached?

    if file.blob.byte_size > 10.megabytes
      errors.add(:file, "must be less than 10 MB")
    end
  end

  # only allow pdf, docx, txt, markdown
  def file_content_type_allowed
    return unless file.attached?

    if [ "application/pdf", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "text/plain", "text/markdown" ].exclude?(file.blob.content_type)
      errors.add(:file, "must be a PDF, DOCX, TXT, or Markdown")
    end
  end
end
