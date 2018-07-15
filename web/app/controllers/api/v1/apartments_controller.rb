module Api::V1
  class ApartmentsController < ApplicationController
    before_action :set_apartment, only: [:update, :destroy]
    before_action :authenticate_user!

    # POST /apartments
    def create
      @apartment = Apartment.new(apartment_params)

      if @apartment.save
        render json: @apartment, status: :created, location: @apartment
      else
        render json: @apartment.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /apartments/1
    def update
      if @apartment.update(apartment_params)
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
    def set_apartment
      @apartment = Apartment.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def apartment_params
      params.require(:apartment).permit(:name, :description, :floor_area_size, :price_per_month, :number_of_rooms, :lat, :lon)
    end
  end
end

