class CustomDevise::SessionsController < Devise::SessionsController
  prepend_before_filter :require_no_authentication, :only => []

  def create
    session["warden.user.user.key"] = nil
    super
    session[:logined_users] ||= [] 
    session[:logined_users] << current_user.id unless session[:logined_users].include?(current_user.id)
  end

  def switch
    user = User.find(params[:id])
    if session[:logined_users] && session[:logined_users].include?(user.id)
      sign_in user, :bypass => true
    else
      flash[:error] = "Not Logined User"
    end
    redirect_to root_path
  end
end
