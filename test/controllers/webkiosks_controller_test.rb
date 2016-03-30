require 'test_helper'

class WebkiosksControllerTest < ActionController::TestCase
  setup do
    @webkiosk = webkiosks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:webkiosks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create webkiosk" do
    assert_difference('Webkiosk.count') do
      post :create, webkiosk: { account_id: @webkiosk.account_id, live: @webkiosk.live, notes: @webkiosk.notes, platform: @webkiosk.platform, url: @webkiosk.url }
    end

    assert_redirected_to webkiosk_path(assigns(:webkiosk))
  end

  test "should show webkiosk" do
    get :show, id: @webkiosk
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @webkiosk
    assert_response :success
  end

  test "should update webkiosk" do
    patch :update, id: @webkiosk, webkiosk: { account_id: @webkiosk.account_id, live: @webkiosk.live, notes: @webkiosk.notes, platform: @webkiosk.platform, url: @webkiosk.url }
    assert_redirected_to webkiosk_path(assigns(:webkiosk))
  end

  test "should destroy webkiosk" do
    assert_difference('Webkiosk.count', -1) do
      delete :destroy, id: @webkiosk
    end

    assert_redirected_to webkiosks_path
  end
end
