class DocumentChunk < ApplicationRecord
  has_neighbors :embedding

  belongs_to :document
  belongs_to :organization
end
