require "test_helper"

class TagsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, password: "password123", password_confirmation: "password123")
    sign_in_as(@user)
  end

  test "index shows user tags" do
    create(:tag, user: @user, name: "природа")

    get tags_path

    assert_response :success
  end

  test "destroy tag" do
    tag = create(:tag, user: @user)

    assert_difference "Tag.count", -1 do
      delete tag_path(tag)
    end

    assert_redirected_to tags_path
  end
end