class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :uploads, dependent: :destroy
  has_many :albums,  dependent: :destroy
  has_many :tags,    dependent: :destroy

  has_one_attached :avatar

  validates :name, length: { maximum: 100 }, allow_blank: true

   # Список ролей
  ROLES = %w[admin user guest].freeze

  before_save :set_default_role, if: :new_record?

  def display_name
    name.presence || email.split("@").first
  end

  def initials
    display_name[0].upcase
  end

  def photos_count
    uploads.count
  end

  def albums_count
    albums.count
  end

  def tags_count
    tags.count
  end

  def favorites_count
    uploads.where(favorite: true).count
  end

  # Проверка роли
  def admin?
    role == 'admin'
  end

  def user?
    role == 'user'
  end

  def guest?
    role == 'guest'
  end

  private

  def set_default_role
    self.role ||= 'user'
  end
end
