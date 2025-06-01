=begin
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test "should get new" do
    get users_new_url
    assert_response :success
  end

  test "should get create" do
    get users_create_url
    assert_response :success
  end
end
=end
