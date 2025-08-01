class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :set_user
  allow_browser versions: :modern

  def set_user
    csrf_token = request.headers["X-CSRF-Token"] || params[:authenticity_token]
    Rails.logger.info "CSRF Token: #{csrf_token}"
    @user = User.find_or_create_by(ip: request.remote_ip)
  end
end
