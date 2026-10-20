require "test_helper"

class UploadsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, password: "password123", password_confirmation: "password123")
    sign_in_as(@user)
  end

  test "create upload with filter, enqueues job" do
    file = fixture_file_upload("demo.jpg", "image/jpeg")

    assert_difference "Upload.count", 1 do
      assert_enqueued_with(job: ProcessUploadJob) do
        post uploads_path, params: {
          upload: { original: file, filter_name: "bw" }
        }
      end
    end

    upload = Upload.last
    assert_equal "bw", upload.filter_name
    assert_redirected_to upload_path(upload)
  end

  test "destroy removes upload" do
    upload = create(:upload, user: @user)

    assert_difference "Upload.count", -1 do
      delete upload_path(upload)
    end

    assert_redirected_to gallery_path
    assert_equal "Фото удалено", flash[:notice]
  end

  test "update title" do
    upload = create(:upload, user: @user, title: nil)

    patch upload_path(upload), params: {
      upload: { title: "Закат на Байкале" }
    }

    assert_redirected_to upload_path(upload)
    assert_equal "Закат на Байкале", upload.reload.title
  end

  test "add_tag attaches tag" do
    upload = create(:upload, user: @user)

    assert_difference ["Tag.count", "PhotoTag.count"], 1 do
      post add_tag_upload_path(upload), params: { tag_name: "природа" }
    end

    assert_response :success
  end

  test "bulk_destroy removes selected" do
    uploads = create_list(:upload, 3, user: @user)

    assert_difference "Upload.count", -3 do
      delete bulk_destroy_uploads_path, params: { upload_ids: uploads.map(&:id) }
    end
  end
end