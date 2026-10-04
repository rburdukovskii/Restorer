require "test_helper"

class PhotoAlbumTest < ActiveSupport::TestCase
  test "responds to upload" do
    assert_respond_to build(:photo_album), :upload
  end

  test "responds to album" do
    assert_respond_to build(:photo_album), :album
  end

  test "пара upload_id + album_id уникальна" do
    upload = create(:upload)
    album = create(:album, user: upload.user)

    create(:photo_album, upload: upload, album: album)
    duplicate = build(:photo_album, upload: upload, album: album)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:upload_id], "уже существует"
  end

  test "разные album для одного upload — валидно" do
    upload = create(:upload)
    album1 = create(:album, user: upload.user)
    album2 = create(:album, user: upload.user)

    create(:photo_album, upload: upload, album: album1)
    second = build(:photo_album, upload: upload, album: album2)

    assert second.valid?
  end
end
