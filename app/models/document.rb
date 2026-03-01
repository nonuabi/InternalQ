class Document < ApplicationRecord
  belongs_to :organization
  has_many :document_chunks, dependent: :destroy

  has_one_attached :file

  validates :status, presence: true
  validates :file, presence: true
  validates :title, presence: true

  validate :file_size_under_limit
  validate :file_content_type_allowed

  private

  def file_size_under_limit
    return unless file.attached?

    if file.blob.byte_size > 1.megabyte
      errors.add(:file, "must be less than 1 MB")
    end
  end

  def file_content_type_allowed
    return unless file.attached?

    if [ "application/pdf", "application/vnd.openxmlformats-officedocument.wordprocessingml.document" ].exclude?(file.blob.content_type)
      errors.add(:file, "must be a PDF or DOCX")
    end
  end
end
