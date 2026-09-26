import { application } from "controllers/application"

import DropzoneController from "controllers/dropzone_controller"
application.register("dropzone", DropzoneController)

import ImagePreviewController from "controllers/image_preview_controller"
application.register("image-preview", ImagePreviewController)

import BeforeAfterController from "controllers/before_after_controller"
application.register("before-after", BeforeAfterController)

import ProgressController from "controllers/progress_controller"
application.register("progress", ProgressController)