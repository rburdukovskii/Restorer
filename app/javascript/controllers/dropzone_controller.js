import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "zone"]
  static outlets = ["image-preview"]

  connect() {
    console.log("[dropzone] connected")

    this._prevent = (event) => {
      event.preventDefault()
      event.stopPropagation()
    }
    document.addEventListener("dragover", this._prevent)
    document.addEventListener("drop", this._prevent)
  }

  disconnect() {
    document.removeEventListener("dragover", this._prevent)
    document.removeEventListener("drop", this._prevent)
  }

  dragOver(event) {
    event.preventDefault()
    event.stopPropagation()
    this.zoneTarget.dataset.dragging = "true"
  }

  dragLeave(event) {
    event.preventDefault()
    event.stopPropagation()
    this.zoneTarget.dataset.dragging = "false"
  }

  drop(event) {
    event.preventDefault()
    event.stopPropagation()
    this.zoneTarget.dataset.dragging = "false"

    const files = event.dataTransfer.files
    if (!files.length) return

    const dt = new DataTransfer()
    for (const file of files) {
        dt.items.add(file)
    }
    this.inputTarget.files = dt.files

    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
    }
}