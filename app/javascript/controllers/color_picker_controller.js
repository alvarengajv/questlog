import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["picker", "card"]

  pick() {
    const color = this.pickerTarget.value
    this.cardTarget.style.borderColor = color
  }
}
