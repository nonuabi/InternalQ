module Search
  class ChunkSearch
    def self.call(organization_id:, query_embedding:, limit: 8)
      DocumentChunk.where(organization_id: organization_id)
      .nearest_neighbors(:embedding, query_embedding, distance: :cosine)
      .limit(limit)
    end
  end
end
