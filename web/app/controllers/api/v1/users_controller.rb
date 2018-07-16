module Api::V1
  class UsersController < ApplicationController
    load_and_authorize_resource param_method: :user_params
    before_action :authenticate_user!, except: [:create]

    def index
      if !current_user.admin?
        render json:{permissions: "none"}
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

    def user_params
      params.require(:user).permit(:email, :password, :name, :role)
    end
  end
end