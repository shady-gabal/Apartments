module Api::V1
  class UsersController < ApplicationController
    before_action :authenticate_user!, except: [:create]

    private

    def user_params
      params.require(:user).permit(:email, :password, :name)
    end
  end
end