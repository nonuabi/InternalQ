class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :integrations, dependent: :destroy
  has_many :question_usages, dependent: :destroy

  validates :name, presence: true
end
