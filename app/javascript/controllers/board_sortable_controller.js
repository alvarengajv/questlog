import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["column"]

  connect() {
    this.sortables = []
    this.columnTargets.forEach(column => this.#initSortable(column))
  }

  disconnect() {
    this.sortables.forEach(s => s.destroy())
    this.sortables = []
  }

  columnTargetConnected(column) {
    this.#initSortable(column)
  }

  columnTargetDisconnected(column) {
    const sortable = this.sortables.find(s => s.el === column)
    if (sortable) {
      sortable.destroy()
      this.sortables = this.sortables.filter(s => s.el !== column)
    }
  }

  #initSortable(column) {
    if (this.sortables.some(s => s.el === column)) return

    const sortable = Sortable.create(column, {
      group: "board-items",
      handle: "[data-drag-handle]",
      draggable: "[data-draggable-item]",
      animation: 150,
      ghostClass: "opacity-30",
      dragClass: "shadow-lg",
      forceFallback: true,
      fallbackOnBody: true,
      fallbackTolerance: 3,
      onEnd: this.#onEnd.bind(this)
    })

    this.sortables.push(sortable)
  }

  #onEnd(event) {
    const { item: el, from, to } = event

    if (from === to) return

    const itemId = el.dataset.itemId
    const sourceListId = from.dataset.taskListId
    const targetListId = to.dataset.taskListId

    if (!itemId || !sourceListId || !targetListId) return

    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    fetch(`/task_lists/${sourceListId}/items/${itemId}/move`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({ target_task_list_id: targetListId })
    }).then(response => {
      if (!response.ok) throw new Error(`Move failed: ${response.status}`)
      return response.text()
    }).then(html => {
      if (html && window.Turbo) {
        window.Turbo.renderStreamMessage(html)
      }
    }).catch(error => {
      console.error("[board-sortable] Move failed:", error)
      from.appendChild(el)
    })
  }
}
