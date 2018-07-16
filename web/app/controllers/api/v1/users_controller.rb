module Api::V1
  class UsersController < ApplicationController
    before_action :set_user, only: [:update, :destroy]
    before_action :authenticate_user!, except: [:create]

    def index
      if !current_user.admin?
        return {permissions: "none"}
      end

      users = User.all.where(:role => [User::Role::CLIENT, User::Role::REALTOR]).where.not(:id => (params[:excluded_ids] || []))

      render json: {data: users, permissions: "crud"}
    end

    def create
      @user = User.new(user_params)

      if @user.save
        render json: @user, status: :created, location: @user
      else
        render json: {errors: @user.errors.full_messages}, status: :unprocessable_entity
      end
    end


    def update
      if @user.update(user_params)
        render json: @user.to_json
      else
        render json: {errors: @user.errors.full_messages}, status: :unprocessable_entity
      end
    end

    def destroy
      if @user.destroy
        render json:{}
      else
        render json:{errors: @user.errors.full_messages}, status: :unprocessable_entity
      end
    end
    
    private

    def set_user
      @user = User.find(params[:id])
    end
    
    def user_params
      params.require(:user).permit(:email, :password, :name)
    end
  end
end