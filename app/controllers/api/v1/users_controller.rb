# app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < BaseController
      # POST /api/v1/users/request_verification
      def request_verification
        phone_number = params[:phone_number]
        
        # Validate phone number format
        unless valid_phone_number?(phone_number)
          return render_error("Invalid phone number format. Use format: 0711222333 or +254711222333")
        end
        
        # Find or create user
        user = User.find_or_create_by!(phone_number: phone_number)
        
        # In development, just return the code
        if Rails.env.development?
          render_success({
            message: "Verification code sent (dev mode)",
            verification_code: user.sms_verification_code,
            user_id: user.id
          })
        else
          # In production, we'd send SMS via Twilio
          render_success({
            message: "Verification code sent to #{phone_number}",
            user_id: user.id
          })
        end
      rescue => e
        render_error("Failed to request verification: #{e.message}")
      end
      
      # POST /api/v1/users/verify
      def verify
        user = User.find(params[:user_id])
        code = params[:verification_code]
        
        if user.verify!(code)
          # Generate a simple token for API access
          token = user.id.to_s  # Simple token for now
          
          render_success({
            message: "Phone number verified successfully",
            token: token,
            user: {
              id: user.id,
              phone_number: user.phone_number,
              trust_score: user.trust_score,
              verified: user.verified?
            }
          })
        else
          render_error("Invalid verification code")
        end
      rescue ActiveRecord::RecordNotFound
        render_error("User not found", :not_found)
      end
      
      # POST /api/v1/users/login
      def login
        phone_number = params[:phone_number]
        
        user = User.find_by(phone_number: phone_number)
        
        if user&.verified?
          token = user.id.to_s  # Simple token
          
          render_success({
            message: "Login successful",
            token: token,
            user: {
              id: user.id,
              phone_number: user.phone_number,
              trust_score: user.trust_score,
              reports_count: user.reports_count
            }
          })
        else
          render_error("User not found or not verified", :unauthorized)
        end
      end
      
      private
      
      def valid_phone_number?(phone)
        # Accept Kenyan phone numbers in various formats
        phone = phone.to_s.gsub(/\s+/, "")
        phone.match?(/^(?:\+?254|0)?[17]\d{8}$/)
      end
    end
  end
end