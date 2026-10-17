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
    chip.className = "inline-flex items-center gap-2 pl-3 pr-1 py-1 rounded-full " +
                    "bg-white text-gray-900 text-sm font-medium " +
                    "border border-gray-200 hover:border-blue-300 transition"

    const nameLink = document.createElement("a")
    nameLink.href = `/tags/${tag.id}/photos`
    nameLink.className = "hover:text-blue-600 transition"
    nameLink.textContent = tag.name
    chip.appendChild(nameLink)

    const button = document.createElement("button")
    button.type = "button"
    button.setAttribute("data-action", "click->tag-input#remove")
    button.setAttribute("data-tag-id", tag.id)
    button.setAttribute("data-tag-name", tag.name)
    button.title = "Удалить тег"
    button.className = "w-5 h-5 rounded-full flex items-center justify-center " +
                      "text-gray-400 hover:text-white hover:bg-red-500 " +
                      "transition cursor-pointer"
    button.innerHTML = `<svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12"/>
    </svg>`
    chip.appendChild(button)

    this.tagsTarget.appendChild(chip)
  }
}