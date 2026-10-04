require "test_helper"

class AlbumTest < ActiveSupport::TestCase
  # === Ассоциации ===
  test "responds to user" do
    assert_respond_to build(:album), :user
  end

  test "responds to uploads" do
    assert_respond_to build(:album), :uploads
  end

  test "responds to photo_albums" do
    assert_respond_to build(:album), :photo_albums
  end

  test "responds to cover" do
    assert_respond_to create(:album), :cover
  end

  # === Валидации ===
  test "name обязателен" do
    album = build(:album, name: nil)
    assert_not album.valid?
    assert_includes album.errors[:name], "не может быть пустым"
  end

  test "name не длиннее 100 символов" do
    album = build(:album, name: "a" * 101)
    assert_not album.valid?
    assert_includes album.errors[:name], "слишком большой длины (не может быть больше чем 100 символов)"
  end

  test "name ровно 100 символов — валидно" do
    album = build(:album, name: "a" * 100)
    assert album.valid?
  end

  # === Скоуп recent ===
  test ".recent сортирует по created_at DESC" do
    user = create(:user)
    old = create(:album, user: user, created_at: 3.days.ago)
    new_album = create(:album, user: user, created_at: 1.hour.ago)

    result = Album.recent.to_a
    assert_equal new_album, result.first
    assert_equal old, result.last
  end

  # === cover_image ===
  test "#cover_image возвращает cover, если привязан" do
    album = create(:album)
    album.cover.attach(
      io: File.open(Rails.root.join("test/fixtures/files/demo.jpg")),
      filename: "cover.jpg",
      content_type: "image/jpeg"
    )

    assert_equal album.cover, album.cover_image
  end

  test "#cover_image возвращает processed первого фото, если cover нет" do
    user = create(:user)
    album = create(:album, user: user)
    upload = create(:upload, :completed, user: user)
    album.uploads << upload

    assert_equal upload.processed.filename.to_s, album.cover_image.filename.to_s
  end

  test "#cover_image возвращает original, если processed нет" do
    user = create(:user)
    album = create(:album, user: user)
    upload = create(:upload, user: user)
    album.uploads << upload

    assert_equal upload.original.filename.to_s, album.cover_image.filename.to_s
  end

  test "#cover_image возвращает nil, если альбом пуст" do
    album = create(:album)
    assert_nil album.cover_image
  end

  # === photos_count ===
  test "#photos_count возвращает количество фото" do
    user = create(:user)
    album = create(:album, user: user)
    uploads = create_list(:upload, 3, user: user)
    uploads.each { |u| album.uploads << u }

    assert_equal 3, album.photos_count
  end

  test "#photos_count возвращает 0 для пустого альбома" do
    album = create(:album)
    assert_equal 0, album.photos_count
  end

  # === Уникальность в альбоме ===
  test "одно фото нельзя добавить дважды" do
    user = create(:user)
    album = create(:album, user: user)
    upload = create(:upload, user: user)
    album.uploads << upload

    assert_raises(ActiveRecord::RecordInvalid) do
      album.uploads << upload
    end
  end

  # === Каскадное удаление ===
  test "удаление album удаляет photo_albums, но не uploads" do
    user = create(:user)
    album = create(:album, user: user)
    upload = create(:upload, user: user)
    album.uploads << upload

    assert_no_difference "Upload.count" do
      assert_difference "PhotoAlbum.count", -1 do
        album.destroy
      end
    end
  end
end
