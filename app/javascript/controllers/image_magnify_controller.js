import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-magnify"
export default class extends Controller {
  static targets = ["image"]

  show(event) {
    // Prevent default link behavior if the image is wrapped in a link
    event.preventDefault()
    
    // Get the image source from the clicked image
    const imageUrl = event.currentTarget.src || event.currentTarget.dataset.imageUrl
    
    if (!imageUrl) {
      console.warn("No image URL found for magnification")
      return
    }

    // Create modal overlay
    const overlay = this.createOverlay(imageUrl)
    document.body.appendChild(overlay)
    
    // Prevent body scroll when modal is open
    document.body.style.overflow = 'hidden'
    
    // Store reference for cleanup
    this.currentOverlay = overlay
    
    // Add event listeners for closing
    this.addCloseListeners(overlay)
    
    // Animate in
    requestAnimationFrame(() => {
      overlay.style.opacity = '1'
      const modalImage = overlay.querySelector('[data-modal-image]')
      if (modalImage) {
        modalImage.style.transform = 'scale(1)'
      }
    })
  }

  createOverlay(imageUrl) {
    const overlay = document.createElement('div')
    overlay.className = 'fixed inset-0 z-50 flex items-center justify-center bg-black/80 transition-opacity p-4 cursor-pointer'
    overlay.style.opacity = '0'
    overlay.dataset.imageMagnifyOverlay = 'true'
    
    overlay.innerHTML = `
      <div class="relative max-w-full max-h-full flex items-center justify-center" onclick="event.stopPropagation()">
        <img 
          src="${imageUrl}" 
          alt="Magnified book cover" 
          class="max-w-full max-h-full object-contain rounded-lg shadow-2xl transition-transform duration-300 ease-out cursor-auto"
          style="transform: scale(0.8)"
          data-modal-image
        />
        <button 
          class="absolute top-4 right-4 bg-white/20 hover:bg-white/30 text-white rounded-full p-2 transition-colors"
          onclick="this.closest('[data-image-magnify-overlay]').dispatchEvent(new CustomEvent('magnify:close'))"
          aria-label="Close magnified view"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>
    `
    
    return overlay
  }

  addCloseListeners(overlay) {
    // Close on click outside
    overlay.addEventListener('click', (event) => {
      if (event.target === overlay) {
        this.close()
      }
    })
    
    // Close on custom event from button
    overlay.addEventListener('magnify:close', () => {
      this.close()
    })
    
    // Close on escape key
    this.escapeHandler = (event) => {
      if (event.key === 'Escape' && this.currentOverlay) {
        this.close()
      }
    }
    document.addEventListener('keydown', this.escapeHandler)
  }

  close() {
    if (!this.currentOverlay) return
    
    // Animate out
    this.currentOverlay.style.opacity = '0'
    const modalImage = this.currentOverlay.querySelector('[data-modal-image]')
    if (modalImage) {
      modalImage.style.transform = 'scale(0.8)'
    }
    
    // Remove after animation
    setTimeout(() => {
      if (this.currentOverlay && this.currentOverlay.parentNode) {
        this.currentOverlay.parentNode.removeChild(this.currentOverlay)
      }
      
      // Restore body scroll
      document.body.style.overflow = ''
      
      // Clean up event listeners
      if (this.escapeHandler) {
        document.removeEventListener('keydown', this.escapeHandler)
        this.escapeHandler = null
      }
      
      this.currentOverlay = null
    }, 300)
  }

  disconnect() {
    // Clean up if controller is disconnected while modal is open
    if (this.currentOverlay) {
      this.close()
    }
  }
}