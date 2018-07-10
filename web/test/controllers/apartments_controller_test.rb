require 'test_helper'

class ApartmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @apartment = apartments(:one)
  end

  test "should get index" do
    get apartments_url, as: :json
    assert_response :success
  end

  test "should create apartment" do
    assert_difference('Apartment.count') do
      post apartments_url, params: { apartment: { decimal,: @apartment.decimal,, decimal,: @apartment.decimal,, decimal,: @apartment.decimal,, decimal: @apartment.decimal, description: @apartment.description, floor_area_size: @apartment.floor_area_size, integer,: @apartment.integer,, lat: @apartment.lat, lon: @apartment.lon, name: @apartment.name, number_of_rooms: @apartment.number_of_rooms, price_per_month: @apartment.price_per_month } }, as: :json
    end

    assert_response 201
  end

  test "should show apartment" do
    get apartment_url(@apartment), as: :json
    assert_response :success
  end

  test "should update apartment" do
    patch apartment_url(@apartment), params: { apartment: { decimal,: @apartment.decimal,, decimal,: @apartment.decimal,, decimal,: @apartment.decimal,, decimal: @apartment.decimal, description: @apartment.description, floor_area_size: @apartment.floor_area_size, integer,: @apartment.integer,, lat: @apartment.lat, lon: @apartment.lon, name: @apartment.name, number_of_rooms: @apartment.number_of_rooms, price_per_month: @apartment.price_per_month } }, as: :json
    assert_response 200
  end

  test "should destroy apartment" do
    assert_difference('Apartment.count', -1) do
      delete apartment_url(@apartment), as: :json
    end

    assert_response 204
  end
end
