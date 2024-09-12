class Api::V1::Admin::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_user, only: %i(show update destroy)

  def index
    @users = User.not_admin
    render json: {
      users: @users.map{|user| UserSerializer.new(user)},
      status: :ok
    }
  end

  def show
    render json: {
      user: UserSerializer.new(@user),
      status: :ok
    }
  end

  def create
    @user = User.new user_params
    if @user.save
      render json: @user, status: :created
    else
      render json: {
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update user_params
      render json: @user, status: :ok
    else
      render json: {
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      render json: {message: t("flash.deleted_user")}, status: :ok
    else
      render json: {
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by id: params[:id]
    return if @user

    render json: {
      errors: t("flash.not_found_user")
    }, status: :not_found
  end

  def user_params
    params.permit User::USER_PARAMS
  end
end
