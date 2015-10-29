class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  def self.default_url_options(options={})
    { locale: I18n.locale }
  end

  protected

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :username << :description
  end

  def user_can_edit?(object)
    unless current_user.can_edit? object
      redirect_to root_path, alert: 'Only authorised users can edit events!'
    end
  end
end
