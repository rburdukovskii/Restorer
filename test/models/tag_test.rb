require "test_helper"

class TagTest < ActiveSupport::TestCase
  # === Ассоциации ===
  test "responds to user" do
    assert_respond_to build(:tag), :user
  end

  test "responds to uploads" do
    assert_respond_to build(:tag), :uploads
  end

  test "responds to photo_tags" do
    assert_respond_to build(:tag), :photo_tags
  end

  # === Валидации ===
  test "name обязателен" do
    tag = build(:tag, name: nil)
    assert_not tag.valid?
    assert_includes tag.errors[:name], "не может быть пустым"
  end

  test "name не длиннее 50 символов" do
    tag = build(:tag, name: "a" * 51)
    assert_not tag.valid?
    assert_includes tag.errors[:name], "слишком большой длины (не может быть больше чем 50 символов)"
  end

  test "name уникален в рамках user" do
    user = create(:user)
    create(:tag, user: user, name: "природа")
    duplicate = build(:tag, user: user, name: "природа")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "уже существует"
  end

  test "два пользователя могут иметь тег с одинаковым именем" do
    user1 = create(:user)
    user2 = create(:user)
    create(:tag, user: user1, name: "природа")

    tag = build(:tag, user: user2, name: "природа")
    assert tag.valid?
  end

  # === Нормализация ===
  test "name нормализуется: trim + downcase" do
    user = create(:user)
    tag = create(:tag, user: user, name: "  ПРИРОДА  ")
    assert_equal "природа", tag.name
  end

  test "name с разным регистром — дубликат" do
    user = create(:user)
    create(:tag, user: user, name: "Природа")
    duplicate = build(:tag, user: user, name: "ПРИРОДА")

    assert_not duplicate.valid?
  end

  test "name с пробелами в начале/конце — дубликат" do
    user = create(:user)
    create(:tag, user: user, name: "природа")
    duplicate = build(:tag, user: user, name: "  природа  ")

    assert_not duplicate.valid?
  end

  # === Скоуп popular ===
  test ".popular сортирует по количеству фото DESC" do
    user = create(:user)
    popular = create(:tag, user: user, name: "популярный")
    rare    = create(:tag, user: user, name: "редкий")

    3.times do
      upload = create(:upload, user: user)
      upload.tags << popular
    end
    upload = create(:upload, user: user)
    upload.tags << rare

    assert_equal popular, Tag.popular.first
  end

  test ".popular не падает, если тегов нет" do
    assert_equal [], Tag.popular.to_a
  end

  # === Каскадное удаление ===
  test "удаление tag удаляет photo_tags, но не uploads" do
    user = create(:user)
    tag = create(:tag, user: user)
    upload = create(:upload, user: user)
    upload.tags << tag

    assert_no_difference "Upload.count" do
      assert_difference "PhotoTag.count", -1 do
        tag.destroy
      end
    end
  end
end
