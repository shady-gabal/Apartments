module Api::V1
  class UsersController < ApplicationController
    before_action :authenticate_user!, except: [:create]

    def create
      @user = User.new(user_params)
      if @user.save
        token = @user.create_new_auth_token
        render json: {user: @user.to_json, token: token}
      else
        render json: {errors: @user.errors}, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :password, :name)
    end
  end
end