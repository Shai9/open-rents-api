class Neighborhood < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }
  
  # has_many :reports
  # has_many :insights
  
  def self.popular_neighborhoods
    order(name: :asc)
  end
  
  private
  
  def generate_slug
    self.slug = name.parameterize
  end
end