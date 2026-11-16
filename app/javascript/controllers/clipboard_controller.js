import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]

  copy() {
    const text = this.sourceTarget.value

    // Проверяем, доступен ли современный API (HTTPS или localhost)
    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(text).then(() => {
        this.#feedback()
      }).catch(() => {
        this.#fallbackCopy(text)
      })
    } else {
      this.#fallbackCopy(text)
    }
  }

  #fallbackCopy(text) {
    this.sourceTarget.focus()
    this.sourceTarget.select()
    this.sourceTarget.setSelectionRange(0, 99999)
    
    try {
      document.execCommand("copy")
      this.#feedback()
    } catch (e) {
      console.error("Ошибка копирования:", e)
    }
  }

  #feedback() {
    // Ищем кнопку внутри контейнера контроллера
    const btn = this.element.querySelector("button")
    if (!btn) return
    
    const prev = btn.textContent
    btn.textContent = "Скопировано!"
    btn.classList.add("bg-emerald-600")
    
    setTimeout(() => {
      btn.textContent = prev
      btn.classList.remove("bg-emerald-600")
    }, 1500)
  }
}