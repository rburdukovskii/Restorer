require "test_helper"

class GalleryFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, password: "password123", password_confirmation: "password123")
    sign_in_as(@user)
  end

  test "shows own uploads only" do
    create_list(:upload, 3, user: @user)
    create_list(:upload, 2, user: create(:user))

    get gallery_path

    assert_response :success
    assert_select ".grid img", count: 3
  end

  test "filter by favorites" do
    create_list(:upload, 3, user: @user, favorite: true)
    create_list(:upload, 2, user: @user, favorite: false)

    get gallery_path(favorites: 1)

    assert_response :success
    assert_select ".grid a[href^='/uploads/']", count: 3
  end

  test "search by title" do
    upload = create(:upload, user: @user, title: "Закат на Байкале")
    create(:upload, user: @user, title: "Кот Барсик")

    get gallery_path(q: "закат")

    assert_response :success
    assert_match "uploads/#{upload.id}", response.body
  end
end