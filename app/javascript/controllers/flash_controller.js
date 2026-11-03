import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.element.style.opacity = "0"
      setTimeout(() => this.element.remove(), 300) // Ждем завершения анимации
    }, 4000) // 4 секунды
  }
}