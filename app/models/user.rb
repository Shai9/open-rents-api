class User < ApplicationRecord
  validates :phone_number, presence: true, uniqueness: true
  validates :trust_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :consistency_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  
  before_validation :format_phone_number
  before_create :generate_verification_code

  has_many :reports, dependent: :destroy
  
  def calculate_trust_score
    score = verified? ? 0.6 : 0.3
    
    if reports_count > 0
      report_bonus = Math.log10(reports_count + 1) * 0.1
      score += report_bonus
    end
    
    score += (consistency_score * 0.3)
    
    score.clamp(0.1, 1.0)
  end
  
  def update_trust_score!
    update!(trust_score: calculate_trust_score)
  end
  
  def calculate_consistency_score
    user_reports = reports.verified
    return 0.5 if user_reports.empty?
    
    total_agreements = user_reports.sum(:agreements_count)
    total_verifications = user_reports.sum { |r| r.agreements_count + r.disagreements_count }
    
    total_verifications.zero? ? 0.5 : (total_agreements.to_f / total_verifications)
  end
  
  scope :verified, -> { where.not(sms_verified_at: nil) }
  scope :trusted, ->(threshold = 0.7) { verified.where("trust_score >= ?", threshold) }
  
  def verified?
    sms_verified_at.present?
  end
  
  def verify!(code)
    return false unless sms_verification_code == code
    
    update!(
      sms_verified_at: Time.current,
      sms_verification_code: nil
    )
  end
  
  private
  
  def format_phone_number
    return if phone_number.blank?
    
    cleaned = phone_number.gsub(/\D/, '')
    
    if cleaned.start_with?('0')
      self.phone_number = "+254#{cleaned[1..]}"
    elsif cleaned.start_with?('254')
      self.phone_number = "+#{cleaned}"
    elsif cleaned.start_with?('+')
      self.phone_number = cleaned
    else
      self.phone_number = "+254#{cleaned}"
    end
  end
  
  def generate_verification_code
    self.sms_verification_code = rand(100000..999999).to_s
  end
end
