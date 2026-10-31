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

  # НОВЫЕ ТЕСТЫ ДЛЯ ДОБАВЛЕНИЯ СУЩЕСТВУЮЩИХ ТЕГОВ

  test "upload show page displays available existing tags" do
    upload = create(:upload, user: @user)
    existing_tag = create(:tag, user: @user, name: "сепия")

    get upload_path(upload)

    assert_response :success
    
    # Проверяем, что блок с существующими тегами отрендерился
    assert_select "p", text: "Ваши существующие теги:"
    
    # Проверяем, что кнопка для тега "сепия" есть и имеет нужные data-атрибуты для JS
    assert_select "button[data-action='click->tag-input#addExisting'][data-tag-name='сепия']", count: 1
  end

  test "add existing tag to upload via POST request" do
    upload = create(:upload, user: @user)
    existing_tag = create(:tag, user: @user, name: "отпуск 2026")

    assert_equal 0, upload.tags.count

    # Имитируем fetch-запрос из JS-контроллера
    post add_tag_upload_path(upload), params: { tag_name: "отпуск 2026" }, as: :json

    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response["success"]
    
    # Проверяем, что тег реально прикрепился в БД
    upload.reload
    assert_equal 1, upload.tags.count
    assert_equal "отпуск 2026", upload.tags.first.name
  end

  test "does not duplicate existing tag on upload" do
    upload = create(:upload, user: @user)
    existing_tag = create(:tag, user: @user, name: "семья")
    
    # Добавляем тег первый раз
    upload.tags << existing_tag
    assert_equal 1, upload.tags.count

    # Пытаемся добавить его же еще раз через запрос
    post add_tag_upload_path(upload), params: { tag_name: "семья" }, as: :json

    assert_response :success
    
    # Убеждаемся, что дубликат не создался
    upload.reload
    assert_equal 1, upload.tags.count
  end
end