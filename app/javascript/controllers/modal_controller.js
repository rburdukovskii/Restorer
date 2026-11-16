import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  close() {
    this.element.remove()
  }

  closeOnBackdrop(event) {
    if (!this.hasPanelTarget) return
    if (!this.panelTarget.contains(event.target)) this.close()
  }

  connect() {
    this._esc = (e) => { if (e.key === "Escape") this.close() }
    document.addEventListener("keydown", this._esc)
  }

  disconnect() {
    document.removeEventListener("keydown", this._esc)
  }
}