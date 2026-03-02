class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  belongs_to :organization, optional: true
  validates :email, presence: true, uniqueness: true
  validate :email_format

  after_create :create_organization_if_missing

  def self.from_google(auth)
    email = auth.info.email.to_s.downcase
    user = find_by(email: email)

    if user
      if user.provider.blank? || user.uid.blank?
        user.update(provider: auth.provider, uid: auth.uid)
      end
      return user
    end

    create!(
      email: email,
      password: Devise.friendly_token[0, 20],
      provider: auth.provider,
      uid: auth.uid
    )
  end

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
