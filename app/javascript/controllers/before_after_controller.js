import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "handle"]

  connect() {
    this._onMove = this.#onMove.bind(this)
    this._onTouch = this.#onTouchMove.bind(this)
    this.element.addEventListener("mousemove", this._onMove)
    this.element.addEventListener("touchmove", this._onTouch)
  }

  disconnect() {
    this.element.removeEventListener("mousemove", this._onMove)
    this.element.removeEventListener("touchmove", this._onTouch)
  }

  #onMove(event) {
    if (event.buttons !== 1) return
    this.#update(event.clientX)
  }

  #onTouchMove(event) {
    this.#update(event.touches[0].clientX)
  }

  #update(clientX) {
    const rect = this.element.getBoundingClientRect()
    let pos = ((clientX - rect.left) / rect.width) * 100
    pos = Math.min(100, Math.max(0, pos))
    this.overlayTarget.style.width = `${pos}%`
    this.handleTarget.style.left = `${pos}%`
  }
}