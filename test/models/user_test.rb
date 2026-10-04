require "test_helper"

class UserTest < ActiveSupport::TestCase
  # === Ассоциации ===
  test "responds to uploads" do
    assert_respond_to build(:user), :uploads
  end

  test "responds to albums" do
    assert_respond_to build(:user), :albums
  end

  test "responds to tags" do
    assert_respond_to build(:user), :tags
  end

  test "has avatar attachment" do
    assert_respond_to create(:user), :avatar
  end

  # === Валидации email ===
  test "email обязателен" do
    user = build(:user, email: nil)
    assert_not user.valid?
    assert_includes user.errors[:email], "не может быть пустым"
  end

  test "email уникален" do
    create(:user, email: "same@example.com")
    duplicate = build(:user, email: "same@example.com")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "уже занят"
  end

  test "email должен быть валидным" do
    user = build(:user, email: "not-an-email")
    assert_not user.valid?
    assert_includes user.errors[:email], "неверный формат"
  end

  # === Валидации password ===
  test "password минимум 6 символов" do
    user = build(:user, password: "123", password_confirmation: "123")
    assert_not user.valid?
    assert user.errors[:password].any?
  end

  # === Валидации name ===
  test "name не длиннее 100 символов" do
    user = build(:user, name: "a" * 101)
    assert_not user.valid?
    assert_includes user.errors[:name], "слишком большой длины (не может быть больше чем 100 символов)"
  end

  test "name может быть пустым" do
    user = build(:user, name: nil)
    user.valid?
    assert_empty user.errors[:name]
  end

  # === display_name ===
  test "display_name возвращает name, если оно есть" do
    user = build(:user, name: "Иван Иванов")
    assert_equal "Иван Иванов", user.display_name
  end

  test "display_name возвращает часть email, если name nil" do
    user = build(:user, name: nil, email: "ivan@example.com")
    assert_equal "ivan", user.display_name
  end

  test "display_name возвращает часть email, если name — пустая строка" do
    user = build(:user, name: "", email: "ivan@example.com")
    assert_equal "ivan", user.display_name
  end

  # === initials ===
  test "initials возвращает первую букву display_name в верхнем регистре" do
    user = build(:user, name: "иван")
    assert_equal "И", user.initials
  end

  test "initials работает с email, если name пустое" do
    user = build(:user, name: nil, email: "ivan@example.com")
    assert_equal "I", user.initials
  end

  # === Счётчики ===
  test "photos_count возвращает количество uploads" do
    user = create(:user)
    create_list(:upload, 3, user: user)
    assert_equal 3, user.photos_count
  end

  test "photos_count возвращает 0, если нет uploads" do
    user = create(:user)
    assert_equal 0, user.photos_count
  end

  test "albums_count возвращает количество albums" do
    user = create(:user)
    create_list(:album, 2, user: user)
    assert_equal 2, user.albums_count
  end

  test "tags_count возвращает количество tags" do
    user = create(:user)
    create_list(:tag, 4, user: user)
    assert_equal 4, user.tags_count
  end

  test "favorites_count возвращает только избранные" do
    user = create(:user)
    create_list(:upload, 2, user: user, favorite: true)
    create(:upload, user: user, favorite: false)
    assert_equal 2, user.favorites_count
  end

  # === Каскадное удаление ===
  test "удаление user удаляет его uploads" do
    user = create(:user)
    create_list(:upload, 2, user: user)

    assert_difference "Upload.count", -2 do
      user.destroy
    end
  end

  test "удаление user удаляет его albums" do
    user = create(:user)
    create_list(:album, 2, user: user)

    assert_difference "Album.count", -2 do
      user.destroy
    end
  end

  test "удаление user удаляет его tags" do
    user = create(:user)
    create_list(:tag, 3, user: user)

    assert_difference "Tag.count", -3 do
      user.destroy
    end
  end
end
