class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    puts "Unauthorized access attempted - returning gracefully"
    render json:{}, status: :unauthorized
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def authenticate_user!
    authenticate_api_v1_user!
  end

  def current_user
    current_api_v1_user
  end
end
