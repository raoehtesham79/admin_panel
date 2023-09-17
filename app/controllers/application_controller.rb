class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    render 'welcome',  alert: 'authorization failed' 
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def after_sign_in_path_for(resource)
    if resource.editor
      posts_path(resource)
    else
      dashboard_posts_path
    end
  end

  def after_sign_out_path_for(resource)
    root_path
  end
end
