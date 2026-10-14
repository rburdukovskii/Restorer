import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "panel", "count", "form", "hiddenInputs"]

  connect() {
    console.log("[bulk-select] connected")
    this.update()
  }

  toggle(event) {
    const checkbox = event.currentTarget
    const label = checkbox.closest("label")

    if (checkbox.checked) {
        label?.classList.add("opacity-100")
    } else {
        label?.classList.remove("opacity-100")
    }

    this.#updateVisual(checkbox)
    this.update()
  }

  update() {
    const checked = this.checkboxTargets.filter((el) => el.checked)
    const count = checked.length

    // Обновить счётчик
    if (this.hasCountTarget) {
      this.countTarget.textContent = count
    }

    // Показать/скрыть панель
    if (this.hasPanelTarget) {
      if (count > 0) {
        this.panelTarget.classList.remove("translate-y-[200%]")
        this.panelTarget.classList.add("translate-y-0")
        } else {
        this.panelTarget.classList.add("translate-y-[200%]")
        this.panelTarget.classList.remove("translate-y-0")
      }
    }

    // Обновить hidden inputs в форме
    if (this.hasHiddenInputsTarget) {
      this.hiddenInputsTarget.innerHTML = ""
      checked.forEach((el) => {
        const input = document.createElement("input")
        input.type = "hidden"
        input.name = "upload_ids[]"
        input.value = el.value
        this.hiddenInputsTarget.appendChild(input)
      })
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

    #updateVisual(checkbox) {
    const span = checkbox.nextElementSibling
    const svg = span?.querySelector("svg")

    if (checkbox.checked) {
        span?.classList.add("bg-blue-600", "border-blue-600")
        span?.classList.remove("bg-white/90")
        svg?.classList.remove("opacity-0")
    } else {
            span?.classList.remove("bg-blue-600", "border-blue-600")
            span?.classList.add("bg-white/90")
            svg?.classList.add("opacity-0")
        }
    }

}