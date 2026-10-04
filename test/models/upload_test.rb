require "test_helper"

class UploadTest < ActiveSupport::TestCase
  # === Ассоциации ===
  test "responds to user" do
    assert_respond_to build(:upload), :user
  end

  test "responds to albums" do
    assert_respond_to build(:upload), :albums
  end

  test "responds to tags" do
    assert_respond_to build(:upload), :tags
  end

  test "responds to photo_albums" do
    assert_respond_to build(:upload), :photo_albums
  end

  test "responds to photo_tags" do
    assert_respond_to build(:upload), :photo_tags
  end

  test "responds to original" do
    assert_respond_to create(:upload), :original
  end

  test "responds to processed" do
    assert_respond_to create(:upload), :processed
  end

  # === Валидации original ===
  test "original обязателен" do
    upload = build(:upload)
    upload.original.detach
    assert_not upload.valid?
    assert_includes upload.errors[:original], "не может быть пустым"
  end

  test "original принимает image/jpeg" do
    upload = build(:upload)
    upload.original.detach
    upload.original.attach(
      io: File.open(Rails.root.join("test/fixtures/files/demo.jpg")),
      filename: "test.jpg",
      content_type: "image/jpeg"
    )
    assert upload.valid?
  end

  test "original принимает image/png" do
    upload = build(:upload)
    upload.original.detach
    upload.original.attach(
      io: File.open(Rails.root.join("test/fixtures/files/demo.jpg")),
      filename: "test.png",
      content_type: "image/png"
    )
    assert upload.valid?
  end

  test "original принимает image/webp" do
    upload = build(:upload)
    upload.original.detach
    upload.original.attach(
      io: File.open(Rails.root.join("test/fixtures/files/demo.jpg")),
      filename: "test.webp",
      content_type: "image/webp"
    )
    assert upload.valid?
  end

  test "original отклоняет application/pdf" do
    upload = build(:upload)
    upload.original.detach
    upload.original.attach(
      io: StringIO.new("pdf content"),
      filename: "doc.pdf",
      content_type: "application/pdf"
    )
    assert_not upload.valid?
    assert_match(/JPG|PNG|WebP/, upload.errors[:original].first)
  end

  test "original отклоняет файлы больше 20 МБ" do
    upload = build(:upload)
    upload.original.detach
    upload.original.attach(
      io: StringIO.new("x" * 21.megabytes),
      filename: "big.jpg",
      content_type: "image/jpeg"
    )
    assert_not upload.valid?
    assert_includes upload.errors[:original].first, "20 МБ"
  end

  # === Статус ===
  test "completed? возвращает true при статусе completed" do
    upload = build(:upload, status: "completed")
    assert upload.completed?
  end

  test "completed? возвращает false при другом статусе" do
    upload = build(:upload, status: "pending")
    assert_not upload.completed?
  end

  test "processing? возвращает true при статусе processing" do
    upload = build(:upload, status: "processing")
    assert upload.processing?
  end

  test "processing? возвращает false при другом статусе" do
    upload = build(:upload, status: "pending")
    assert_not upload.processing?
  end

  # === display_title ===
  test "display_title возвращает title, если он есть" do
    upload = build(:upload, title: "Моё фото")
    assert_equal "Моё фото", upload.display_title
  end

  test "display_title возвращает дату, если title nil" do
    upload = build(:upload, title: nil, created_at: Time.zone.local(2026, 9, 27))
    assert_match(/27\.09\.2026/, upload.display_title)
  end

  test "display_title возвращает дату, если title — пустая строка" do
    upload = build(:upload, title: "", created_at: Time.zone.local(2026, 9, 27))
    assert_match(/27\.09\.2026/, upload.display_title)
  end

  # === Скоуп favorites ===
  test ".favorites возвращает только избранные" do
    user = create(:user)
    fav = create(:upload, user: user, favorite: true)
    not_fav = create(:upload, user: user, favorite: false)

    assert_includes Upload.favorites, fav
    assert_not_includes Upload.favorites, not_fav
  end

  # === Скоуп recent ===
  test ".recent сортирует по created_at DESC" do
    user = create(:user)
    old = create(:upload, user: user, created_at: 2.days.ago)
    new_photo = create(:upload, user: user, created_at: 1.hour.ago)

    result = Upload.recent.to_a
    assert_equal new_photo, result.first
    assert_equal old, result.last
  end

  # === Скоуп with_tag ===
  test ".with_tag возвращает uploads с определённым тегом" do
    user = create(:user)
    tag = create(:tag, user: user, name: "природа")
    tagged = create(:upload, user: user)
    tagged.tags << tag
    untagged = create(:upload, user: user)

    result = Upload.with_tag("природа")
    assert_includes result, tagged
    assert_not_includes result, untagged
  end

  test ".with_tag работает с тегом в верхнем регистре" do
    user = create(:user)
    tag = create(:tag, user: user, name: "природа")
    tagged = create(:upload, user: user)
    tagged.tags << tag

    result = Upload.with_tag("ПРИРОДА")
    assert_includes result, tagged
  end

  # === Скоуп in_album ===
  test ".in_album возвращает uploads из альбома" do
    user = create(:user)
    album = create(:album, user: user)
    in_album = create(:upload, user: user)
    in_album.albums << album
    outside = create(:upload, user: user)

    result = Upload.in_album(album.id)
    assert_includes result, in_album
    assert_not_includes result, outside
  end

  # === Скоуп without_album ===
  test ".without_album возвращает uploads без альбомов" do
    user = create(:user)
    album = create(:album, user: user)
    with_album = create(:upload, user: user)
    with_album.albums << album
    without = create(:upload, user: user)

    result = Upload.without_album
    assert_includes result, without
    assert_not_includes result, with_album
  end

  # === add_tags ===
  test "#add_tags добавляет теги к upload" do
    user = create(:user)
    upload = create(:upload, user: user)

    assert_difference "upload.tags.count", 2 do
      upload.add_tags(["природа", "лето"])
    end
  end

  test "#add_tags нормализует имена тегов" do
    user = create(:user)
    upload = create(:upload, user: user)

    upload.add_tags(["ПРИРОДА", "  Лето  "])
    assert_equal ["лето", "природа"], upload.tags.map(&:name).sort
  end

  test "#add_tags не дублирует теги" do
    user = create(:user)
    upload = create(:upload, user: user)

    upload.add_tags(["природа"])
    upload.add_tags(["природа"])

    assert_equal 1, upload.tags.count
  end

  test "#add_tags переиспользует существующие теги пользователя" do
    user = create(:user)
    existing = create(:tag, user: user, name: "природа")
    upload = create(:upload, user: user)

    upload.add_tags(["природа"])
    assert_equal existing, upload.tags.first
  end

  test "#add_tags с пустым массивом ничего не делает" do
    upload = create(:upload)
    assert_no_difference "upload.tags.count" do
      upload.add_tags([])
    end
  end

  # === remove_tag ===
  test "#remove_tag удаляет тег из upload" do
    user = create(:user)
    upload = create(:upload, user: user)
    upload.add_tags(["природа", "лето"])

    assert_difference "upload.tags.count", -1 do
      upload.remove_tag("природа")
    end
  end

  test "#remove_tag нормализует имя" do
    user = create(:user)
    upload = create(:upload, user: user)
    upload.add_tags(["природа"])

    upload.remove_tag("ПРИРОДА")
    assert_equal 0, upload.tags.count
  end

  test "#remove_tag не падает, если тега нет" do
    user = create(:user)
    upload = create(:upload, user: user)

    assert_no_difference "upload.tags.count" do
      upload.remove_tag("несуществующий")
    end
  end

  # === M2M ===
  test "upload может быть в нескольких альбомах" do
    user = create(:user)
    upload = create(:upload, user: user)
    album1 = create(:album, user: user)
    album2 = create(:album, user: user)

    upload.albums << [album1, album2]
    assert_equal 2, upload.albums.count
  end

  test "upload может иметь несколько тегов" do
    user = create(:user)
    upload = create(:upload, user: user)
    upload.add_tags(["природа", "лето", "отпуск"])

    assert_equal 3, upload.tags.count
  end

  # === Каскадное удаление ===
  test "удаление upload удаляет photo_albums" do
    user = create(:user)
    upload = create(:upload, user: user)
    album = create(:album, user: user)
    upload.albums << album

    assert_difference "PhotoAlbum.count", -1 do
      upload.destroy
    end
  end

  test "удаление upload удаляет photo_tags" do
    user = create(:user)
    upload = create(:upload, user: user)
    tag = create(:tag, user: user)
    upload.tags << tag

    assert_difference "PhotoTag.count", -1 do
      upload.destroy
    end
  end
end
