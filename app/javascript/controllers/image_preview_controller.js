import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "canvas", "zone", "removeButton"]

  connect() {
    console.log("[image-preview] connected")
  }

  show() {
    const file = this.sourceTarget.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (e) => {
      this.canvasTarget.src = e.target.result
      this.canvasTarget.hidden = false

      // Скрываем зону загрузки
      if (this.hasZoneTarget) {
        this.zoneTarget.hidden = true
      }

      // Показываем кнопку "Удалить"
      if (this.hasRemoveButtonTarget) {
        this.removeButtonTarget.hidden = false
      }
    }
    reader.readAsDataURL(file)
  }

  remove(event) {
    event.preventDefault()
    event.stopPropagation()

    // Очищаем input
    this.sourceTarget.value = ""

    // Скрываем превью
    this.canvasTarget.src = ""
    this.canvasTarget.hidden = true

    // Показываем зону загрузки обратно
    if (this.hasZoneTarget) {
      this.zoneTarget.hidden = false
    }

    // Скрываем кнопку "Удалить"
    if (this.hasRemoveButtonTarget) {
      this.removeButtonTarget.hidden = true
    }
  }
}