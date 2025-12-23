class Report < ApplicationRecord
  belongs_to :user
  belongs_to :neighborhood
  
  REPORT_TYPES = {
    water_reliability: "Water Reliability",
    security: "Security",
    noise_levels: "Noise Levels",
    internet_speed: "Internet Speed",
    garbage_collection: "Garbage Collection",
    parking_availability: "Parking Availability",
    transport_access: "Transport Access",
    air_quality: "Air Quality",
    flooding_risk: "Flooding Risk",
    power_reliability: "Power Reliability"
  }.freeze
  
  VALUES_BY_TYPE = {
    water_reliability: ["Excellent", "Good", "Fair", "Poor", "Very Poor"],
    security: ["Very Safe", "Safe", "Moderate", "Unsafe", "Very Unsafe"],
    noise_levels: ["Very Quiet", "Quiet", "Moderate", "Noisy", "Very Noisy"],
    internet_speed: ["Excellent", "Good", "Fair", "Poor", "No Service"],
    garbage_collection: ["Daily", "Weekly", "Irregular", "Never"],
    parking_availability: ["Plentiful", "Available", "Limited", "None"],
    transport_access: ["Excellent", "Good", "Fair", "Poor", "None"],
    air_quality: ["Excellent", "Good", "Fair", "Poor", "Very Poor"],
    flooding_risk: ["None", "Low", "Moderate", "High", "Very High"],
    power_reliability: ["24/7", "Regular", "Irregular", "Frequent Outages", "No Power"]
  }.freeze
  
  validates :report_type, presence: true, inclusion: { in: REPORT_TYPES.keys.map(&:to_s) }
  validates :value, presence: true
  validates :user_id, uniqueness: { scope: [:neighborhood_id, :report_type], 
                                   message: "can only submit one report per type per neighborhood" }
  

  before_validation :set_default_confidence, on: :create
  after_create :update_user_report_count
  after_save :trigger_insight_recalculation, if: :verified_changed?
  
  scope :verified, -> { where.not(verified_at: nil) }
  scope :unverified, -> { where(verified_at: nil) }
  scope :for_neighborhood, ->(neighborhood_id) { where(neighborhood_id: neighborhood_id) }
  scope :by_type, ->(type) { where(report_type: type) }
  scope :recent, -> { where("created_at > ?", 30.days.ago) }
  
  def verified?
    verified_at.present?
  end
  
  def verify!
    update!(verified_at: Time.current)
  end
  
  def unverify!
    update!(verified_at: nil)
  end
  
  def consensus_score
    return 0.5 if agreements_count + disagreements_count == 0
    agreements_count.to_f / (agreements_count + disagreements_count)
  end
  
  def total_verifications
    agreements_count + disagreements_count
  end
  
  def agreement_percentage
    return 0 if total_verifications == 0
    (consensus_score * 100).round(2)
  end
  
  def to_api_json
    {
      id: id,
      report_type: report_type,
      value: value,
      details: details,
      confidence: confidence,
      consensus: {
        agreements: agreements_count,
        disagreements: disagreements_count,
        total: total_verifications,
        percentage: agreement_percentage
      },
      verified: verified?,
      verified_at: verified_at,
      user: {
        id: user.id,
        trust_score: user.trust_score,
        reports_count: user.reports_count
      },
      neighborhood: {
        id: neighborhood.id,
        name: neighborhood.name,
        slug: neighborhood.slug
      },
      created_at: created_at,
      updated_at: updated_at
    }
  end
  
  private
  
  def set_default_confidence
    self.confidence ||= user&.trust_score || 0.5
  end
  
  def update_user_report_count
    user.increment!(:reports_count)
  end
  
  def trigger_insight_recalculation
    Rails.logger.info "Report #{id} verification changed, triggering recalculation for neighborhood #{neighborhood_id}"
  end
  
  def verified_changed?
    verified_at_previously_changed?
  end
end
