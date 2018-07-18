module Api::V1
  class UsersController < ApplicationController
    before_action :authenticate_user!, except: [:create]
    before_action :set_user, only: [:update, :destroy]

    def index
      authorize! :read, Client
      authorize! :read, Realtor

      users = User.where(:role => [User::Role::CLIENT, User::Role::REALTOR]).where.not(:id => (params[:excluded_ids] || [])).limit(20)

      render json: {data: users, permissions: "crud"}
    end

    def create
      @user = User.new(user_params)
      authorize! :create, Client if @user.client?
      authorize! :create, Realtor if @user.realtor?
      authorize! :create, Admin if @user.admin?

      if @user.save
        render json: @user.to_json, status: :created
      else
        render json: {errors: @user.errors.full_messages}, status: :unprocessable_entity
      end
    end


    def update
      @user.assign_attributes(user_params)
      authorize! :update, Client if @user.client?
      authorize! :update, Realtor if @user.realtor?
      authorize! :update, Admin if @user.admin?

      if @user.save
        render json: @user.to_json
      else
        render json: {errors: @user.errors.full_messages}, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, Client if @user.client?
      authorize! :destroy, Realtor if @user.realtor?
      authorize! :destroy, Admin if @user.admin?

      if @user.destroy
        render json:{}
      else
        render json:{errors: @user.errors.full_messages}, status: :unprocessable_entity
      end
    end
    
    private

    def user_params
      data = params.require(:user).permit(:email, :password, :name, :role, :realtor)
      realtor_email = data.delete(:realtor)
      if !realtor_email.blank?
        data[:realtor] = User.find_by_email(realtor_email)
      end

      data
    end

    def set_user
      @user = User.find_by_id params[:id]
    end
  end
end