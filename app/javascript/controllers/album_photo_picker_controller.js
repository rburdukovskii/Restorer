import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "checkbox", "count"]
  static values  = { url: String }

  connect() {
    console.log("[album-photo-picker] connected")
  }

  open(event) {
    event.preventDefault()
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
    this.update()
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.modalTarget.classList.remove("flex")
  }

  toggle(event) {
    const checkbox = event.currentTarget
    this.#updateVisual(checkbox)
    this.update()
  }

  update() {
    const checked = this.checkboxTargets.filter((el) => el.checked)
    if (this.hasCountTarget) {
      this.countTarget.textContent = checked.length
    }
  }

  selectAll() {
    this.checkboxTargets.forEach((el) => {
      el.checked = true
      this.#updateVisual(el)
    })
    this.update()
  }

  deselectAll() {
    this.checkboxTargets.forEach((el) => {
      el.checked = false
      this.#updateVisual(el)
    })
    this.update()
  }

  async submit(event) {
    event.preventDefault()

    const checked = this.checkboxTargets.filter((el) => el.checked)
    if (checked.length === 0) {
      alert("Выберите хотя бы одно фото")
      return
    }

    const formData = new FormData()
    checked.forEach((el) => formData.append("upload_ids[]", el.value))

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
      this.showFlash(data.message)

      setTimeout(() => {
        window.location.reload()
      }, 800)
    } else {
      alert(data.error || "Ошибка")
    }
  }

  #updateVisual(checkbox) {
    const span = checkbox.nextElementSibling
    const svg = span?.querySelector("svg")

    if (checkbox.checked) {
      span?.classList.add("bg-blue-600", "border-blue-600")
      svg?.classList.remove("opacity-0")
    } else {
      span?.classList.remove("bg-blue-600", "border-blue-600")
      svg?.classList.add("opacity-0")
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