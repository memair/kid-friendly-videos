class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def memair
    @user = User.from_memair_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in(:user, @user)
      redirect_to root_path
    else
      session['devise.memair_data'] = request.env['omniauth.auth'].except(:extra) # Removing extra as it can overflow some session stores
      redirect_to root_path, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    flash[:error] = 'You must authorize Kid Friendly Videos so that it can make recommendations in the Memair Player'
    redirect_to root_path
 end
end
