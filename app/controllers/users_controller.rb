class UsersController < ApplicationController
  private

  def user_params
    params.require(:user).permit User::ACCOUNT_PARAMS
  end

  def create
    @user = User.new(user_params)
    if @user.save
      reset_session
      log_in @user
    else
      render :new
    end
  end
end
