import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="celebration-modal"
export default class extends Controller {
  static targets = ["overlay", "modal"]

  connect() {
    // Show modal with animation
    this.show()
    
    // Auto-close after 15 seconds if user doesn't interact
    this.autoCloseTimeout = setTimeout(() => {
      this.close()
    }, 15000)
  }

  disconnect() {
    if (this.autoCloseTimeout) {
      clearTimeout(this.autoCloseTimeout)
    }
  }

  show() {
    // Enable smooth animation
    if (this.hasOverlayTarget) {
      this.overlayTarget.style.opacity = "0"
    }
    if (this.hasModalTarget) {
      this.modalTarget.style.transform = "scale(0.5) rotate(-5deg)"
    }
    
    // Force reflow
    if (this.hasOverlayTarget) {
      this.overlayTarget.offsetHeight
    }
    
    // Animate in with more engaging animation
    if (this.hasOverlayTarget) {
      this.overlayTarget.style.transition = "opacity 0.4s ease-out"
      this.overlayTarget.style.opacity = "1"
    }
    
    if (this.hasModalTarget) {
      this.modalTarget.style.transition = "transform 0.5s cubic-bezier(0.34, 1.56, 0.64, 1)"
      this.modalTarget.style.transform = "scale(1) rotate(0deg)"
    }

    // Add a subtle pulse animation to the modal after it appears
    setTimeout(() => {
      if (this.hasModalTarget) {
        this.modalTarget.style.animation = "pulse 2s ease-in-out"
      }
    }, 500)
  }

  close() {
    // Clear auto-close timeout
    if (this.autoCloseTimeout) {
      clearTimeout(this.autoCloseTimeout)
    }

    // Animate out with more engaging animation
    if (this.hasOverlayTarget) {
      this.overlayTarget.style.transition = "opacity 0.3s ease-in"
      this.overlayTarget.style.opacity = "0"
    }
    if (this.hasModalTarget) {
      this.modalTarget.style.transition = "transform 0.3s ease-in"
      this.modalTarget.style.transform = "scale(0.8) rotate(2deg)"
    }
    
    // Remove from DOM after animation
    setTimeout(() => {
      if (this.element && this.element.parentNode) {
        this.element.parentNode.removeChild(this.element)
      }
    }, 300)
  }

  // Close when clicking on overlay (but not the modal itself)
  clickOverlay(event) {
    if (this.hasOverlayTarget && event.target === this.overlayTarget) {
      this.close()
    }
  }

  // Close on Escape key
  keydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}