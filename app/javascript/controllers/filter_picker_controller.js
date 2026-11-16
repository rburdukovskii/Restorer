import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "option"]

  connect() {
    if (this.inputTarget.value) {
      this.selectBySlug(this.inputTarget.value)
    }
  }

  select(event) {
    const slug = event.currentTarget.dataset.slug
    this.inputTarget.value = slug
    this.selectBySlug(slug)
  }

  selectBySlug(slug) {
    // 1. Подсветка выбранной кнопки
    this.optionTargets.forEach((option) => {
      if (option.dataset.slug === slug) {
        option.classList.add("border-blue-600", "bg-blue-50")
        option.classList.remove("border-gray-200")
      } else {
        option.classList.remove("border-blue-600", "bg-blue-50")
        option.classList.add("border-gray-200")
      }
    })

    // 2. Применение CSS-фильтров
    const img = this.element.querySelector('[data-image-preview-target="canvas"]')
    if (!img) return

    // Сброс
    img.style.filter = "none"
    img.style.opacity = "1"

    switch (slug) {
      case "original":
        img.style.filter = "none"
        break

      case "bw":
        img.style.filter = "grayscale(1)"
        break

      case "sepia":
        img.style.filter = "sepia(0.8)"
        break

      case "retro":
        img.style.filter = "saturate(0.6) sepia(0.3) brightness(1.05) contrast(0.9)"
        break

      case "sharpen":
        img.style.filter = "contrast(1.2) saturate(1.1)"
        break

      case "warm":
        img.style.filter = "saturate(1.15) brightness(1.05) sepia(0.15) hue-rotate(-10deg)"
        break

      case "cold":
        img.style.filter = "saturate(0.9) hue-rotate(180deg) brightness(1.02)"
        break

      case "vivid":
        img.style.filter = "saturate(1.4) contrast(1.15)"
        break

      default:
        img.style.filter = "none"
    }
  }
}