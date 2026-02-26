class CreateDocumentChunks < ActiveRecord::Migration[8.0]
  def change
    create_table :document_chunks do |t|
      t.references :document, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.integer :chunk_index, null: false
      t.text :content, null: false
      t.jsonb :metadata, null: false, default: {}
      t.column :embedding, "vector(1536)"
      t.timestamps
    end

    add_index :document_chunks, [:organization_id, :document_id]
    add_index :document_chunks, :embedding, using: :ivfflat, opclass: :vector_cosine_ops
  end
end
