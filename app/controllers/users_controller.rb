class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      success_signup
    else
      fail_signup
    end
  end

  private

  def user_params
    params.require(:user).permit User::ACCOUNT_PARAMS
  end

  def success_signup
    @user.send_activation_email
    flash[:info] = t "flash.check_email_activation"
    redirect_to login_path, status: :see_other
  end

  def fail_signup
    flash[:warning] = t "flash.sign_up_fail"
    render :new, status: :unprocessable_entity
  end
end
