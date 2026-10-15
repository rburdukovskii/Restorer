import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "tags", "container"]
  static values  = { addUrl: String, removeUrl: String }

  connect() {
    console.log("[tag-input] connected")
  }

  async add(event) {
    event.preventDefault()

    const name = this.inputTarget.value.trim()
    if (!name) return

    const formData = new FormData()
    formData.append("tag_name", name)

    const response = await fetch(this.addUrlValue, {
      method: "POST",
      body: formData,
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "application/json"
      }
    })

    const data = await response.json()

    if (data.success) {
      this.addTagToDOM(data.tag)
      this.inputTarget.value = ""
    } else {
      alert(data.error || "Ошибка")
    }
  }

  async remove(event) {
    event.preventDefault()

    const tagId = event.currentTarget.dataset.tagId
    const tagName = event.currentTarget.dataset.tagName

    if (!confirm(`Удалить тег «${tagName}»?`)) return

    const formData = new FormData()
    formData.append("tag_name", tagName)

    const response = await fetch(this.removeUrlValue, {
      method: "DELETE",
      body: formData,
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "application/json"
      }
    })

    const data = await response.json()

    if (data.success) {
      event.currentTarget.closest("[data-tag-id]")?.remove()
    }
  }

  addTagToDOM(tag) {
    const chip = document.createElement("span")
    chip.dataset.tagId = tag.id
    chip.className = "inline-flex items-center gap-1 px-3 py-1 rounded-full bg-blue-50 text-blue-700 text-sm"
    chip.innerHTML = `
      ${tag.name}
      <button type="button"
              data-action="click->tag-input#remove"
              data-tag-id="${tag.id}"
              data-tag-name="${tag.name}"
              class="text-blue-500 hover:text-red-500 transition">
        &times;
      </button>
    `
    this.tagsTarget.appendChild(chip)
  }
}