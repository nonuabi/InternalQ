class Document < ApplicationRecord
  belongs_to :organization
  has_many :document_chunks, dependent: :destroy

  has_one_attached :file

  validates :status, presence: true
end