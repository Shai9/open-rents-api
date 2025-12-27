# app/controllers/api/v1/database_controller.rb
module Api
  module V1
    class DatabaseController < BaseController
      def status
        begin
          # Test database connection
          ActiveRecord::Base.connection.execute("SELECT 1")
          
          # Get counts
          neighborhoods = Neighborhood.count
          users = User.count
          reports = Report.count
          verifications = Verification.count
          
          render_success({
            status: "connected",
            checks: {
              connection_test: "passed",
              query_execution: "successful"
            },
            counts: {
              neighborhoods: neighborhoods,
              users: users,
              reports: reports,
              verifications: verifications
            },
            uptime: calculate_uptime
          })
        rescue => e
          render_error("Database error: #{e.message}", :service_unavailable)
        end
      end
      
      private
      
      def calculate_uptime
        # Simple uptime calculation
        start_time = File.ctime("/proc/1") rescue Time.current - 3600
        (Time.current - start_time).to_i
      end
    end
  end
end