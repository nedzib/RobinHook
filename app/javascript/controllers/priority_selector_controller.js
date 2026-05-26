import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "fire"]

  connect() {
    this.updateVisuals(this.inputTarget.value || 1)
  }

  select(event) {
    const value = event.currentTarget.dataset.value
    this.inputTarget.value = value
    this.updateVisuals(value)
  }

  updateVisuals(selectedValue) {
    this.fireTargets.forEach(el => {
      const value = parseInt(el.dataset.value)
      const colorClass = el.dataset.color
      if (value <= selectedValue) {
        el.classList.add(colorClass)
        el.classList.remove("text-gray-300")
      } else {
        el.classList.add("text-gray-300")
        el.classList.remove(colorClass)
      }
    })
  }
}
