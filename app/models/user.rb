class User < ApplicationRecord
  has_secure_password
  before_save :downcase_email
  before_create :create_activation_digest
  ACCOUNT_PARAMS = %i(user_name email phone
                      password password_confirmation).freeze

  enum role: {user: 0, admin: 1}, _prefix: true
  VALID_EMAIL_REGEX = Regexp.new(Settings.value.valid_email)
  VALID_PHONE_REGEX = Regexp.new(Settings.value.phone_format)

  validates :user_name, presence: true,
    length: {maximum: Settings.value.max_user_name}
  validates :email, presence: true,
    length: {maximum: Settings.value.max_user_email},
    format: {with: VALID_EMAIL_REGEX},
    uniqueness: true
  validates :password, presence: true,
    length: {minimum: Settings.value.min_user_password},
    allow_nil: true
  validates :phone,
            length: {is: Settings.value.phone},
            format: {with: VALID_PHONE_REGEX}

  has_many :addresses, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_one_attached :image
  attr_accessor :remember_token, :activation_token

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update_column :remember_digest, nil
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
