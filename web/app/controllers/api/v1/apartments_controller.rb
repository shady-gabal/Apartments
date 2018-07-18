module Api::V1
  class ApartmentsController < ApplicationController
    load_and_authorize_resource param_method: :apartment_params, except: [:index]
    before_action :set_apartment, only: [:update, :destroy]
    before_action :authenticate_user!

    def index
      authorize! :read, Apartment
      filters = params[:filters] || {}
      apartments = Apartment.where.not(:id => (params[:excluded_ids] || []))

      filters.each do |filter, vals|
        min = vals[0]
        max = vals[1]

        if min.blank? || (!max.blank? && min.to_f > max.to_f)
          next
        end

        if filter == "floor_area_size"
          apartments = apartments.where("floor_area_size >= ?", min.to_f)
          apartments = apartments.where("floor_area_size <= ?", max.to_f) unless max.blank?
        elsif filter == "price_per_month"
          apartments = apartments.where("price_per_month >= ?", min.to_i)
          apartments = apartments.where("price_per_month <= ?", max.to_i) unless max.blank?
        elsif filter == "number_of_rooms"
          apartments = apartments.where("number_of_rooms >= ?", min.to_i)
          apartments = apartments.where("number_of_rooms <= ?", max.to_i) unless max.blank?
        end
      end

      if current_user.client?
        apartments = apartments.where(:rented => false)
      end

      apartments = apartments.limit(20)

      realtor_emails = User.where(:role => User::Role::REALTOR).select(:email).map {|u| u.email}

      render json: {data: apartments.map {|a| a.to_json}, permissions: current_user.client? ? "view" : "crud", availableRealtorEmails: realtor_emails}
    end

    # POST /apartments
    def create
      data = apartment_params
      realtor_email = data.delete(:realtor)
      realtor = !realtor_email.blank? ? User.find_by_email(realtor_email) : nil

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
      data = params.require(:apartment).permit(:name, :description, :floor_area_size, :price_per_month, :number_of_rooms, :lat, :lon, :realtor)
      data[:price_per_month] = (data[:price_per_month].to_f * 100.0).to_i unless data[:price_per_month].nil?

      data
    end
  end
end

