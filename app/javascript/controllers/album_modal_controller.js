import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "albumRadio", "newAlbumInput", "newAlbumWrapper"]
  static values  = { url: String }

  connect() {
    console.log("[album-modal] connected")
  }

  open(event) {
    event.preventDefault()

    const bulkController = this.application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller~="bulk-select"]'),
      "bulk-select"
    )

    const ids = bulkController?.checkboxTargets
      .filter((el) => el.checked)
      .map((el) => el.value) || []

    if (ids.length === 0) {
      alert("Выберите хотя бы одно фото")
      return
    }

    this.uploadIds = ids
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")

    // Сбросить форму
    this.albumRadioTargets.forEach((el) => (el.checked = false))
    if (this.hasNewAlbumInputTarget) {
      this.newAlbumInputTarget.value = ""
    }
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.modalTarget.classList.remove("flex")
  }

  toggleNewAlbum(event) {
    const isNew = event.currentTarget.value === "new"
    if (this.hasNewAlbumWrapperTarget) {
      this.newAlbumWrapperTarget.classList.toggle("hidden", !isNew)
    }
  }

  async submit(event) {
    event.preventDefault()

    const formData = new FormData()
    this.uploadIds.forEach((id) => formData.append("upload_ids[]", id))

    const selectedAlbum = this.albumRadioTargets.find((el) => el.checked)
    const newName = this.hasNewAlbumInputTarget ? this.newAlbumInputTarget.value.trim() : ""

    if (newName) {
      formData.append("new_album_name", newName)
    } else if (selectedAlbum) {
      formData.append("album_id", selectedAlbum.value)
    } else {
      alert("Выберите альбом или создайте новый")
      return
    }

    const response = await fetch(this.urlValue, {
      method: "POST",
      body: formData,
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "application/json"
      }
    })

    const data = await response.json()

    if (data.success) {
      this.close()
      
      const bulkController = this.application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller~="bulk-select"]'),
        "bulk-select"
      )
      bulkController?.deselectAll()

      // Флеш
    this.showFlash(data.message)

    setTimeout(() => { window.location.reload() }, 800) 
    } else { 
        alert(data.error || "Ошибка") 
      }
    }

  showFlash(message) {
    const flash = document.createElement("div")
    flash.className = "fixed top-4 left-1/2 -translate-x-1/2 z-50 bg-emerald-500 text-white px-6 py-3 rounded-lg shadow-lg"
    flash.textContent = message
    document.body.appendChild(flash)
    setTimeout(() => flash.remove(), 3000)
  }
}