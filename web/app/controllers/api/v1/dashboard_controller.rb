module Api::V1
  class DashboardController < ApplicationController
    before_action :authenticate_user!

    def index
      if current_user.admin?
        apartments = Apartment.all
        
      elsif current_user.realtor?

      elsif current_user.client?

      else
        render json:{}, status: 400
      end
    end
  end
end

