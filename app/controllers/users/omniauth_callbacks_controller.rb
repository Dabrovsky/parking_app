# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  attr_reader :service, :user

  # You should also create an action method in this controller like this:
  def slack
    if user_signed_in?
      @user = current_user
    else
      @user = User.from_omniauth(auth).user
    end

    if @user.present?
      @user.services.update(service_attrs)
    else
      @user = create_user
      @user.services.create(service_attrs)
    end

    if user_signed_in?
      redirect_to root_url
    else
      sign_in_and_redirect @user, event: :authentication
    end
  end

  protected

  def auth
    request.env['omniauth.auth']
  end

  def service_attrs
    expires_at = auth.credentials.expires_at.present? ? Time.at(auth.credentials.expires_at) : nil
    {
      provider: auth.provider,
      uid: auth.uid,
      expires_at: expires_at,
      access_token: auth.credentials.token,
      access_token_secret: auth.credentials.secret,
    }
  end

  def create_user
    user_attr = {
      email: auth.info.email,
      name: auth.info.name,
      password: Devise.friendly_token[0,20]
    }

    User.create!(user_attr)
  end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
