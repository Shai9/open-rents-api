class Neighborhood < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  has_many :reports, dependent: :destroy

  def self.popular_neighborhoods
    order(name: :asc)
  end
  
  def as_json(options = {})
    super(options.merge(
      only: [:id, :name, :slug, :county, :ward],
      methods: [:reports_count, :verified_reports_count, :average_confidence]
    ))
  end
  
  def reports_count
    reports.count
  end
  
  def verified_reports_count
    reports.verified.count
  end
  
  def average_confidence
    reports.verified.average(:confidence)&.round(2) || 0.5
  end
  
  def recent_insights
    report_types = Report::REPORT_TYPES.keys.map(&:to_s)
    
    report_types.map do |type|
      {
        type: type,
        value: dominant_value_for(type),
        confidence: confidence_for(type),
        sample_size: reports.verified.by_type(type).count
      }
    end.compact
  end
  
  private
  
  def dominant_value_for(report_type)
    reports.verified.by_type(report_type)
           .group(:value)
           .count
           .max_by { |_, count| count }
           &.first || "No data"
  end
  
  def confidence_for(report_type)
    reports.verified.by_type(report_type)
           .average(:confidence)
           &.round(2) || 0.0
  end
  
  private
  
  def generate_slug
    self.slug = name.parameterize
  end
end