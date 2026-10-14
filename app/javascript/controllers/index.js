//v2
import { application } from "controllers/application"

import DropzoneController from "controllers/dropzone_controller"
application.register("dropzone", DropzoneController)

import ImagePreviewController from "controllers/image_preview_controller"
application.register("image-preview", ImagePreviewController)

import BeforeAfterController from "controllers/before_after_controller"
application.register("before-after", BeforeAfterController)

import ProgressController from "controllers/progress_controller"
application.register("progress", ProgressController)

import FilterPickerController from "controllers/filter_picker_controller"
application.register("filter-picker", FilterPickerController)

import BulkSelectController from "controllers/bulk_select_controller"
application.register("bulk-select", BulkSelectController)

import AlbumModalController from "controllers/album_modal_controller"
application.register("album-modal", AlbumModalController)

import AlbumPhotoPickerController from "controllers/album_photo_picker_controller"
application.register("album-photo-picker", AlbumPhotoPickerController)