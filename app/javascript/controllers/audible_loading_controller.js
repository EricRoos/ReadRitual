import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audible-loading"
export default class extends Controller {
  static targets = ["overlay", "modal", "step1", "step2", "step3", "step4"]

  connect() {
    // Show modal with animation
    this.show()
    
    // Start progress simulation
    this.startProgressSimulation()
    
    // Set timeout to handle potential failures
    this.failureTimeout = setTimeout(() => {
      this.showError()
    }, 60000) // 60 seconds max
  }

  disconnect() {
    if (this.progressInterval) {
      clearInterval(this.progressInterval)
    }
    if (this.failureTimeout) {
      clearTimeout(this.failureTimeout)
    }
  }

  show() {
    // Enable smooth animation
    if (this.hasOverlayTarget) {
      this.overlayTarget.style.opacity = "0"
    }
    if (this.hasModalTarget) {
      this.modalTarget.style.transform = "scale(0.5) rotate(-2deg)"
    }
    
    // Force reflow
    if (this.hasOverlayTarget) {
      this.overlayTarget.offsetHeight
    }
    
    // Animate in
    if (this.hasOverlayTarget) {
      this.overlayTarget.style.transition = "opacity 0.4s ease-out"
      this.overlayTarget.style.opacity = "1"
    }
    
    if (this.hasModalTarget) {
      this.modalTarget.style.transition = "transform 0.5s cubic-bezier(0.34, 1.56, 0.64, 1)"
      this.modalTarget.style.transform = "scale(1) rotate(0deg)"
    }
  }

  startProgressSimulation() {
    let currentStep = 1
    const steps = [
      { target: "step1", text: "Connecting to Audible...", delay: 1000 },
      { target: "step2", text: "Downloading book page...", delay: 3000 },
      { target: "step3", text: "Extracting book details...", delay: 2000 },
      { target: "step4", text: "Creating your book entry...", delay: 2000 }
    ]

    // Activate first step immediately
    this.activateStep(1)

    // Progress through steps
    this.progressInterval = setInterval(() => {
      if (currentStep < steps.length) {
        currentStep++
        this.activateStep(currentStep)
      } else {
        // Reset to simulate ongoing work
        this.resetSteps()
        currentStep = 1
        this.activateStep(1)
      }
    }, 2500) // Progress every 2.5 seconds
  }

  activateStep(stepNumber) {
    // Reset all steps
    this.resetSteps()
    
    // Activate current and previous steps
    for (let i = 1; i <= stepNumber; i++) {
      const target = this[`step${i}Target`]
      if (target) {
        const dot = target.querySelector('.w-2')
        if (i === stepNumber) {
          // Current step - orange and pulsing
          dot.className = "w-2 h-2 bg-orange-500 rounded-full animate-pulse"
        } else {
          // Completed steps - green
          dot.className = "w-2 h-2 bg-green-500 rounded-full"
        }
      }
    }
  }

  resetSteps() {
    [this.step1Target, this.step2Target, this.step3Target, this.step4Target].forEach(target => {
      if (target) {
        const dot = target.querySelector('.w-2')
        dot.className = "w-2 h-2 bg-gray-300 dark:bg-gray-600 rounded-full"
      }
    })
  }

  close() {
    // Clear intervals and timeouts
    if (this.progressInterval) {
      clearInterval(this.progressInterval)
    }
    if (this.failureTimeout) {
      clearTimeout(this.failureTimeout)
    }

    // Animate out
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

  cancel() {
    // Redirect back or close modal
    window.location.reload()
  }

  showError() {
    // Could implement error state here
    console.log("Audible fetch is taking longer than expected")
  }

  // Close when clicking on overlay (but not the modal itself)
  clickOverlay(event) {
    if (this.hasOverlayTarget && event.target === this.overlayTarget) {
      // Don't allow closing during loading for better UX
      // this.cancel()
    }
  }

  // Handle Escape key
  keydown(event) {
    if (event.key === "Escape") {
      this.cancel()
    }
  }
}