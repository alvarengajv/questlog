import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  remove() {
    this.element.classList.add("item-exit")
    this.element.addEventListener("animationend", () => {
      this.element.remove()
    }, { once: true })
  }
}
