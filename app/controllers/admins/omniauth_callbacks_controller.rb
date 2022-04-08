class Admins::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @admin = Admin.from_omniauth(request.env['omniauth.auth'])

    if @admin.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect @admin, event: :authentication
    else
      session['devise.google_data'] = request.env['omniauth.auth'].except('extra') # Removing extra as it can overflow some session stores
      redirect_to new_admin_registration_url, alert: @admin.errors.full_messages.join("\n")
    end
  end

  def failure
    redirect_to root_path
  end
end