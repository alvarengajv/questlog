import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.sortable = Sortable.create(this.element, {
      handle: "[data-sortable-handle]",
      animation: 150,
      ghostClass: "opacity-30",
      onEnd: this.#onEnd.bind(this)
    })
  }

  disconnect() {
    if (this.sortable) this.sortable.destroy()
  }

  #onEnd() {
    const itemIds = Array.from(this.element.children).map(el => {
      const match = el.id.match(/item_(\d+)/)
      return match ? match[1] : null
    }).filter(Boolean)

    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
        "Accept": "application/json"
      },
      body: JSON.stringify({ item_ids: itemIds })
    })
  }
}
