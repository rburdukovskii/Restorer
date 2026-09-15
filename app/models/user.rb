class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

   # Список ролей
  ROLES = %w[admin user guest].freeze

  before_save :set_default_role, if: :new_record?

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
