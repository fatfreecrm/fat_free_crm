require 'test_helper'

class KiosksControllerTest < ActionController::TestCase
  setup do
    @kiosk = kiosks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kiosks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kiosk" do
    assert_difference('Kiosk.count') do
      post :create, kiosk: { cd_password: @kiosk.cd_password, contract_length: @kiosk.contract_length, contract_type: @kiosk.contract_type, name: @kiosk.name, notes: @kiosk.notes, password: @kiosk.password, purchase_date: @kiosk.purchase_date }
    end

    assert_redirected_to kiosk_path(assigns(:kiosk))
  end

  test "should show kiosk" do
    get :show, id: @kiosk
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @kiosk
    assert_response :success
  end

  test "should update kiosk" do
    patch :update, id: @kiosk, kiosk: { cd_password: @kiosk.cd_password, contract_length: @kiosk.contract_length, contract_type: @kiosk.contract_type, name: @kiosk.name, notes: @kiosk.notes, password: @kiosk.password, purchase_date: @kiosk.purchase_date }
    assert_redirected_to kiosk_path(assigns(:kiosk))
  end

  test "should destroy kiosk" do
    assert_difference('Kiosk.count', -1) do
      delete :destroy, id: @kiosk
    end

    assert_redirected_to kiosks_path
  end
end
