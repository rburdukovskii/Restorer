import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bar", "percent", "label"]
  static values = { url: String, interval: { type: Number, default: 1500 } }

  connect() {
    this.timer = setInterval(() => this.#poll(), this.intervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  #poll() {
    fetch(this.urlValue, { headers: { Accept: "application/json" } })
      .then((res) => res.json())
      .then((data) => this.#update(data))
      .catch(() => clearInterval(this.timer))
  }

  #update(data) {
    if (data.progress !== undefined) {
      this.barTarget.style.width = `${data.progress}%`
      this.percentTarget.textContent = `${data.progress}%`
    }

    if (data.status === "completed") {
      clearInterval(this.timer)
      this.labelTarget.textContent = "Готово!"
      if (data.redirect_url) window.location.href = data.redirect_url
      return
    }

    if (data.status === "failed") {
      clearInterval(this.timer)
      this.labelTarget.textContent = "Ошибка обработки"
      this.labelTarget.classList.add("text-red-600")
      this.barTarget.style.background = "#EF4444"
      // Показать сообщение
      const errorMsg = document.createElement("p")
      errorMsg.className = "text-xs text-red-500 mt-2"
      errorMsg.textContent = "Попробуйте другой фильтр или загрузите фото ещё раз."
      this.element.appendChild(errorMsg)
      return
    }
  }
}