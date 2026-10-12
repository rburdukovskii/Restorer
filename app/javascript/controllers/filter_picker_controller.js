import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "option"]

  select(event) {
    const button = event.currentTarget
    const slug = button.dataset.slug

    this.inputTarget.value = slug

    this.optionTargets.forEach((el) => {
      el.classList.remove("border-blue-600", "bg-blue-50")
      el.classList.add("border-gray-200")
    })

    button.classList.remove("border-gray-200")
    button.classList.add("border-blue-600", "bg-blue-50")
  }
}