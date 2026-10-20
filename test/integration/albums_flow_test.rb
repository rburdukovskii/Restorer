require "test_helper"

class AlbumsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, password: "password123", password_confirmation: "password123")
    sign_in_as(@user)
  end

  test "create album" do
    assert_difference "Album.count", 1 do
      post albums_path, params: { album: { name: "Отпуск" } }
    end

    assert_redirected_to gallery_path
  end

  test "destroy album doesn't destroy photos" do
    album = create(:album, user: @user)
    upload = create(:upload, user: @user)
    album.uploads << upload

    assert_no_difference "Upload.count" do
      assert_difference "Album.count", -1 do
        delete album_path(album)
      end
    end
  end
end