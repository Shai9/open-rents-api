# app/controllers/api/v1/neighborhoods_controller.rb
module Api
  module V1
    class NeighborhoodsController < BaseController
      def index
        neighborhoods = Neighborhood.popular_neighborhoods
        render_success(neighborhoods.map(&:as_json))
      end
      
      def show
        neighborhood = Neighborhood.find_by!(slug: params[:id])
        render_success(neighborhood.as_json)
      rescue ActiveRecord::RecordNotFound
        render_error("Neighborhood not found", :not_found)
      end
      
      def reports
        neighborhood = if params[:id].to_i > 0
          Neighborhood.find(params[:id])
        else
          Neighborhood.find_by!(slug: params[:id])
        end
        
        # Get reports with ordering for the main list
        reports = neighborhood.reports.includes(:user)
                              .order(created_at: :desc)
        
        # Get verified reports count
        verified_reports_count = neighborhood.reports.verified.count
        
        # Get report types count (without order clause)
        report_types_count = neighborhood.reports
                                        .group(:report_type)
                                        .count
        
        render_success({
          neighborhood: {
            id: neighborhood.id,
            name: neighborhood.name,
            slug: neighborhood.slug
          },
          reports: reports.map(&:to_api_json),
          summary: {
            total_reports: reports.count,
            verified_reports: verified_reports_count,
            report_types: report_types_count
          }
        })
      rescue ActiveRecord::RecordNotFound
        render_error("Neighborhood not found", :not_found)
      end
      
      def insights
        neighborhood = if params[:id].to_i > 0
          Neighborhood.find(params[:id])
        else
          Neighborhood.find_by!(slug: params[:id])
        end
        
        render_success({
          neighborhood: {
            id: neighborhood.id,
            name: neighborhood.name,
            slug: neighborhood.slug
          },
          insights: neighborhood.recent_insights,
          last_updated: Time.current.iso8601
        })
      rescue ActiveRecord::RecordNotFound
        render_error("Neighborhood not found", :not_found)
      end
    end
  end
end