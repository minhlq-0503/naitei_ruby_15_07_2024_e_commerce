class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]
    if user && !user.activated && user.authenticated?(:activation, params[:id])
      success_activate user
    else
      fail_activate
    end
  end

  private

  def success_activate user
    user.activate
    log_in user
    flash[:success] = t "flash.success_activate"
    redirect_to root_path
  end

  def fail_activate
    flash[:danger] = t "flash.fail_activate"
    redirect_to root_url
  end
end
