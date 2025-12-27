module Api
  module V1
    class UsersController < BaseController
      def request_verification
        phone_number = params[:phone_number]
        
        unless valid_phone_number?(phone_number)
          return render_error("Invalid phone number format. Use format: 0711222333 or +254711222333")
        end
        
        user = User.find_or_create_by!(phone_number: phone_number)
        
        if Rails.env.development?
          render_success({
            message: "Verification code sent (dev mode)",
            verification_code: user.sms_verification_code,
            user_id: user.id
          })
        else
          render_success({
            message: "Verification code sent to #{phone_number}",
            user_id: user.id
          })
        end
      rescue => e
        render_error("Failed to request verification: #{e.message}")
      end
      
      def verify
        user = User.find(params[:user_id])
        code = params[:verification_code]
        
        if user.verify!(code)
          token = user.id.to_s 
          
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
      
      def login
        phone_number = params[:phone_number]
        
        user = User.find_by(phone_number: phone_number)
        
        if user&.verified?
          token = user.id.to_s  
          
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
        phone = phone.to_s.gsub(/\s+/, "")
        phone.match?(/^(?:\+?254|0)?[17]\d{8}$/)
      end
    end
  end
end