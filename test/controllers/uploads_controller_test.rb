require "test_helper"

class UploadsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user, password: "password123", password_confirmation: "password123")
    post user_session_path, params: {
      user: { email: @user.email, password: "password123" }
    }
  end

  test "should get new" do
    get new_upload_url
    assert_response :success
  end
end