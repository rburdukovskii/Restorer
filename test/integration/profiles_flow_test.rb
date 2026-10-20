require "test_helper"

class ProfilesFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, password: "password123", password_confirmation: "password123")
    sign_in_as(@user)
  end

  test "show profile" do
    get profile_path
    assert_response :success
  end

  test "update name" do
    patch profile_path, params: { user: { name: "Новое имя" } }
    assert_equal "Новое имя", @user.reload.name
  end

  test "requires authentication" do
    delete destroy_user_session_path
    get profile_path
    assert_redirected_to new_user_session_path
  end
end