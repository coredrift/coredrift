require "test_helper"

class DailiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

=begin
  test "should get new" do
    get dailies_new_url
    assert_response :success
  end

  test "should get create" do
    get dailies_create_url
    assert_response :success
  end

  test "should get showbin/rails" do
    get dailies_showbin/rails_url
    assert_response :success
  end

  test "should get generate" do
    get dailies_generate_url
    assert_response :success
  end

  test "should get controller" do
    get dailies_controller_url
    assert_response :success
  end

  test "should get Dailies" do
    get dailies_Dailies_url
    assert_response :success
  end

  test "should get show" do
    get dailies_show_url
    assert_response :success
  end

  definidos = []
  instance_methods(false).grep(/^test_/).each do |m|
    if definidos.include?(m)
      remove_method(m)
    else
      definidos << m
    end
  end
=end
end
