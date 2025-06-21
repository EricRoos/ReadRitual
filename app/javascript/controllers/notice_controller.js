import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="notice"
export default class extends Controller {
  static targets = ["container"]

  connect() {
    if (this.hasContainerTarget) {
      setTimeout(() => {
        this.fadeOut()
      }, 3500) // 3.5 seconds delay
    }
  }

  fadeOut() {
    this.containerTarget.style.transition = "opacity 0.5s ease"
    this.containerTarget.style.opacity = "0"
    setTimeout(() => {
      this.containerTarget.remove()
    }, 500) // Remove after fade-out
  }
}