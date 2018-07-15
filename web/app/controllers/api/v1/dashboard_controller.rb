module Api::V1
  class DashboardController < ApplicationController
    before_action :authenticate_user!

    def index
      json = {}
      apartment_params = params[:apartments] || {}
      user_params = params[:users] || {}

      json.merge!({ apartments: fetch_apartments(apartment_params[:excluded_ids]) })
      json.merge!({ users: fetch_users(user_params[:excluded_ids]) })

      render json: json
    end

    private

    def fetch_apartments(ids_to_ignore=[])
      apartments = Apartment.where.not(:id => ids_to_ignore)
      if current_user.client?
        apartments = apartments.where(:rented => false)
      end

      return {data: apartments.map {|a| a.to_json}, permissions: current_user.client? ? "view" : "crud"}
    end

    def fetch_users(ids_to_ignore=[])
      if !current_user.admin?
        return {permissions: "none"}
      end

      users = User.all.where.not(:id => ids_to_ignore)

      data = {realtors: [], clients: [], permissions: "crud"}

      users.each do |u|
        if u.realtor?
          data[:realtors] << u
        elsif u.client?
          data[:clients] << u
        end
      end

      return data
    end
  end
end

