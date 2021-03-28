class ApplicationController < ActionController::Base

before_action :is_logeado



 private
  def is_logeado
     if !user_signed_in? && !params[:controller].include?("users") && !params[:controller].include?("devise")
       flash[:warning] = "Debes iniciar sesión"
       return redirect_to(new_user_session_path)
     end
  end
end
