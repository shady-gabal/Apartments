module Api::V1
  class ApartmentsController < ApplicationController
    load_and_authorize_resource param_method: :apartment_params
    before_action :set_apartment, only: [:update, :destroy]
    before_action :authenticate_user!

    def index
      apartments = Apartment.where.not(:id => (params[:excluded_ids] || []))
      if current_user.client?
        apartments = apartments.where(:rented => false)
      end
      realtor_emails = User.where(:role => User::Role::REALTOR).select(:email).map {|u| u.email}

      render json: {data: apartments.map {|a| a.to_json}, permissions: current_user.client? ? "view" : "crud", availableRealtorEmails: realtor_emails}
    end

    # POST /apartments
    def create
      data = apartment_params
      realtor_email = data.delete(:realtor)
      realtor = realtor_email ? User.find_by_email(realtor_email) : nil

      @apartment = Apartment.new(data)
      @apartment.realtor = realtor

      if @apartment.save
        render json: @apartment, status: :created, location: @apartment
      else
        render json:{errors: @apartment.errors.full_messages}, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /apartments/1
    def update
      data = apartment_params
      realtor_email = data.delete(:realtor)
      realtor = !realtor_email.blank? ? User.find_by_email(realtor_email) : nil

      @apartment.assign_attributes(data)
      @apartment.realtor = realtor

      if @apartment.save
        render json: @apartment.to_json
      else
        render json: {errors: @apartment.errors.full_messages}, status: :unprocessable_entity
      end
    end

    # DELETE /apartments/1
    def destroy
      if @apartment.destroy
        render json:{}
      else
        render json:{errors: @apartment.errors.full_messages}, status: :unprocessable_entity
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    # def set_apartment
    #   @apartment = Apartment.find(params[:id])
    # end

    # Only allow a trusted parameter "white list" through.
    def apartment_params
      params.require(:apartment).permit(:name, :description, :floor_area_size, :price_per_month, :number_of_rooms, :lat, :lon, :realtor)
    end
  end
end

