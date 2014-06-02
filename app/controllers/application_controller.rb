class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :mobile_device?

  before_action :prepare_for_mobile

  private
    def current_user
      if session[:admin]
        @current_user ||= 'admin'
      elsif session[:bookshelf_id]
        @current_user ||= Bookshelf.find(session[:bookshelf_id])
      end
    end

    def add_flash(type, message)
      flash[type] ||= []
      flash[type] << message
    end

    def mobile_device?
      request.user_agent =~ /Mobile|webOS/
    end

    def prepare_for_mobile
      request.variant = :mobile if mobile_device?
    end
end