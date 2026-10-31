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

  addExisting(event) {
    event.preventDefault()
    
    const tagName = event.currentTarget.dataset.tagName
    const tagId = event.currentTarget.dataset.tagId
    
    // Отправляем запрос на сервер
    fetch(this.addUrlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Accept": "application/json"
      },
      body: JSON.stringify({ tag_name: tagName })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // Создаем HTML для нового тега в списке активных
        const tagHtml = `
          <span data-tag-id="${data.tag.id}" class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-blue-100 text-blue-700 text-sm font-medium">
            #${data.tag.name}
            <button type="button"
                    data-action="click->tag-input#remove"
                    data-tag-id="${data.tag.id}"
                    data-tag-name="${data.tag.name}"
                    class="text-blue-500 hover:text-red-500 transition ml-1">
              &times;
            </button>
          </span>
        `
        // Добавляем в контейнер
        this.tagsTarget.insertAdjacentHTML("beforeend", tagHtml)
        
        // Удаляем кнопку из списка существующих
        event.currentTarget.remove()
      } else {
        alert(data.error || "Ошибка добавления тега")
      }
    })
  }

  async remove(event) {
    event.preventDefault()

    const tagId = event.currentTarget.dataset.tagId
    const tagName = event.currentTarget.dataset.tagName
    
    // Ищем родительский SPAN (плашку), а не саму кнопку
    const tagElement = event.currentTarget.closest(`span[data-tag-id="${tagId}"]`)

    if (!tagElement) {
      console.error("Не найден элемент плашки")
      return
    }

    // Делаем плашку полупрозрачной
    tagElement.style.opacity = '0.5'
    tagElement.style.pointerEvents = 'none'

    const formData = new FormData()
    formData.append("tag_name", tagName)

    try {
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
        // Удаляем всю плашку
        tagElement.remove()
      } else {
        // Восстанавливаем, если ошибка
        tagElement.style.opacity = '1'
        tagElement.style.pointerEvents = 'auto'
      }
    } catch (error) {
      tagElement.style.opacity = '1'
      tagElement.style.pointerEvents = 'auto'
      console.error("Ошибка удаления тега:", error)
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