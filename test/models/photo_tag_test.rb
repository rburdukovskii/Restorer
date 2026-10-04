require "test_helper"

class PhotoTagTest < ActiveSupport::TestCase
  test "responds to upload" do
    assert_respond_to build(:photo_tag), :upload
  end

  test "responds to tag" do
    assert_respond_to build(:photo_tag), :tag
  end

  test "пара upload_id + tag_id уникальна" do
    upload = create(:upload)
    tag = create(:tag, user: upload.user)

    create(:photo_tag, upload: upload, tag: tag)
    duplicate = build(:photo_tag, upload: upload, tag: tag)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:upload_id], "уже существует"
  end

  test "разные tag для одного upload — валидно" do
    upload = create(:upload)
    tag1 = create(:tag, user: upload.user)
    tag2 = create(:tag, user: upload.user)

    create(:photo_tag, upload: upload, tag: tag1)
    second = build(:photo_tag, upload: upload, tag: tag2)

    assert second.valid?
  end
end
