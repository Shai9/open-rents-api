# app/models/user.rb
class User < ApplicationRecord
  # Validations
  validates :phone_number, presence: true, uniqueness: true
  validates :trust_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :consistency_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  
  # Callbacks
  before_validation :format_phone_number
  before_create :generate_verification_code
  
  # Scopes
  scope :verified, -> { where.not(sms_verified_at: nil) }
  scope :trusted, ->(threshold = 0.7) { verified.where("trust_score >= ?", threshold) }
  
  # Instance Methods
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
    
    # Clean and format phone number (Kenya specific)
    cleaned = phone_number.gsub(/\D/, '')
    
    # Convert to +254 format if it starts with 0 or 254
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
