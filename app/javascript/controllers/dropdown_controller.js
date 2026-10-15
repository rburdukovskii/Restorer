import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "arrow"]

  connect() {
    this._onClickOutside = this.#onClickOutside.bind(this)
    document.addEventListener("click", this._onClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this._onClickOutside)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
    this.arrowTarget?.classList.toggle("rotate-180")
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.arrowTarget?.classList.remove("rotate-180")
  }

  #onClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}