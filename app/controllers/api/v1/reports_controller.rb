module Api
  module V1
    class ReportsController < BaseController
      before_action :authenticate_user!, only: [:create, :update, :destroy]
      before_action :set_report, only: [:show, :update, :destroy]
      
    def index
      reports = Report.includes(:user, :neighborhood)
      
      reports = reports.for_neighborhood(params[:neighborhood_id]) if params[:neighborhood_id]
      
      reports = reports.by_type(params[:report_type]) if params[:report_type]
      
      reports = params[:verified] == 'true' ? reports.verified : reports if params[:verified].present?
      
      reports = reports.order(created_at: :desc)
      
      reports = reports.page(params[:page]).per(params[:per_page] || 20)
      
      render_success({
        reports: reports.map(&:to_api_json),
        pagination: {
          current_page: reports.current_page,
          total_pages: reports.total_pages,
          total_count: reports.total_count,
          per_page: reports.limit_value
        }
      })
    end
      
      def show
        render_success(@report.to_api_json)
      end
      
      def create
        @report = current_user.reports.new(report_params)
        
        if @report.save
          render_success(@report.to_api_json, :created)
        else
          render_error(@report.errors.full_messages.join(', '))
        end
      end
      
      def update
        if @report.update(report_params)
          render_success(@report.to_api_json)
        else
          render_error(@report.errors.full_messages.join(', '))
        end
      end
      
      def destroy
        @report.destroy
        render_success(message: "Report deleted successfully")
      end
      
      private
      
      def set_report
        @report = Report.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error("Report not found", :not_found)
      end
      
      def report_params
        params.require(:report).permit(:neighborhood_id, :report_type, :value, :details)
      end
      
      def authenticate_user!
        token = request.headers['Authorization']&.split(' ')&.last
        @current_user = User.find_by(id: token) if token
        
        return if @current_user&.verified?
        
        render_error("Authentication required. Please login first.", :unauthorized)
      end
      
      def current_user
        @current_user
      end
    end
  end
end