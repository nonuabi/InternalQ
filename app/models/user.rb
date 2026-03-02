class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :organization, optional: true
  validates :email, presence: true, uniqueness: true
  validate :email_format

  after_create :create_organization_if_missing

  def create_organization_if_missing
    unless organization.present?
      base_name = "#{email.split('@').first}'s Org"
      name = base_name
      suffix = 0
      while Organization.exists?(name: name)
        suffix += 1
        name = "#{base_name} #{suffix}"
      end
      org = Organization.create!(name: name)
      update!(organization_id: org.id, role: "admin")
    end
  end

  def admin?
    role == "admin"
  end

  def employee?
    role == "employee"
  end

  def email_format
    unless email.match?(/\A[^@\s]+@[^@\s]+\.[^@\s]+\z/)
      errors.add(:email, "is not a valid email address")
    end
  end
end
