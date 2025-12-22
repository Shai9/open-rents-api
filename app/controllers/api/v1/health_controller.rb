module Api
  module V1
    class HealthController < BaseController
      def index
        begin
          neighborhoods_count = Neighborhood.count
          users_count = User.count
          
          render_success({
            status: "healthy",
            timestamp: Time.current.iso8601,
            environment: Rails.env,
            database: "connected",
            neighborhoods_count: neighborhoods_count,
            users_count: users_count,
            checks: {
              database_query: "successful",
              connection: "active"
            }
          })
        rescue => e
          render_success({
            status: "degraded",
            timestamp: Time.current.iso8601,
            environment: Rails.env,
            database: "disconnected",
            error: e.message,
            neighborhoods_count: 0,
            users_count: 0,
            checks: {
              database_query: "failed",
              connection: "inactive"
            }
          })
        end
      end
    end
  end
end