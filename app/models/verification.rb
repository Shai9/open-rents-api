class Verification < ApplicationRecord
  belongs_to :user
  belongs_to :report
  
  validates :agrees, inclusion: { in: [true, false] }
  validates :user_id, uniqueness: { scope: :report_id, 
                                   message: "can only verify a report once" }
  validate :user_cannot_verify_own_report
  
  after_create :update_report_counts
  after_destroy :update_report_counts
  
  def to_api_json
    {
      id: id,
      agrees: agrees,
      comment: comment,
      weight: weight,
      user: {
        id: user.id,
        trust_score: user.trust_score
      },
      created_at: created_at
    }
  end
  
  private
  
  def user_cannot_verify_own_report
    if user_id == report.user_id
      errors.add(:user_id, "cannot verify your own report")
    end
  end
  
  def update_report_counts
    report.update!(
      agreements_count: report.verifications.where(agrees: true).count,
      disagreements_count: report.verifications.where(agrees: false).count
    )
    
    report.update_confidence!
    
    user.update!(consistency_score: user.calculate_consistency_score)
  end
end
