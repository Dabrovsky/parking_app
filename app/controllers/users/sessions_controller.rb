# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    resource = User.find_for_database_authentication(email: params[:user][:email])

    return invalid_login_attempt({
      email: 'Invalid email or password',
      password: 'Invalid email or password'
    }) unless resource

    return invalid_login_attempt({
      password: 'Invalid password'
    }) unless resource.valid_password?(params[:user][:password])

    sign_in :user, resource
    return render nothing: true
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  def invalid_login_attempt(errors)
    render json: { errors: errors }, status: :unprocessable_entity
  end
end
