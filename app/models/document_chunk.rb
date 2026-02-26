class DocumentChunk < ApplicationRecord
  belongs_to :document
  belongs_to :organization
end