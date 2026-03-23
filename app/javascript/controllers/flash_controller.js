import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 3000 } }

  connect() {
    this.timeout = setTimeout(() => this.dismiss(), this.delayValue)
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.style.transition = "opacity 0.5s ease, transform 0.5s ease"
    this.element.style.opacity = "0"
    this.element.style.transform = "translateY(10px)"
    setTimeout(() => this.element.remove(), 500)
  }
}
