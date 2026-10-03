class Tag < ApplicationRecord
  belongs_to :user
  has_many :photo_tags, dependent: :destroy
  has_many :uploads, through: :photo_tags

  validates :name, presence: true,
                   length: { maximum: 50 },
                   uniqueness: { scope: :user_id, case_sensitive: false }

  before_validation :normalize_name

  scope :popular, -> { left_joins(:photo_tags).group(:id).order("COUNT(photo_tags.id) DESC") }

  private

  def normalize_name
    self.name = name.strip.downcase if name.present?
  end
end
