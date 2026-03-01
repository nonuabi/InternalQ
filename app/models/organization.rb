class Organization < ApplicationRecord
  has_many :users
  has_many :documents
  has_many :integrations

  validates :name, presence: true
end
