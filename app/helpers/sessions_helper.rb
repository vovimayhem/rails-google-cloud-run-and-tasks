module SessionsHelper
  def authenticate_user!
    return if user_signed_in?

    redirect_to new_session_path
  end

  def sign_in_user(user)
    session[:current_user] = user
  end

  def current_user
    User.new session[:current_user]
  end

  def user_signed_in?
    session.key? :current_user
  end

  def sign_out_user
    session.delete :current_user
  end
end
