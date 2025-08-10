import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audible-form"
export default class extends Controller {
  static targets = ["input", "submit", "form", "loadingModal"]

  showLoading(event) {
    // Only show loading if there's an Audible URL
    const url = this.inputTarget.value.trim()
    if (!url) {
      return // Let the form validation handle this
    }

    // Check if it's an Audible URL
    const isAudibleUrl = this.isValidAudibleUrl(url)
    if (!isAudibleUrl) {
      return // Let the form validation handle this
    }

    // Show the loading modal by removing the hidden class
    if (this.hasLoadingModalTarget) {
      this.loadingModalTarget.classList.remove('hidden')
    }
    
    // Disable the submit button to prevent double submission
    this.submitTarget.disabled = true
    this.submitTarget.innerHTML = '<span>Processing...</span>'
  }

  isValidAudibleUrl(url) {
    try {
      const urlObj = new URL(url)
      return urlObj.hostname === 'www.audible.com' || urlObj.hostname === 'audible.com'
    } catch {
      return false
    }
  }

  hideLoading() {
    if (this.hasLoadingModalTarget) {
      this.loadingModalTarget.classList.add('hidden')
    }
    
    // Re-enable the submit button
    this.submitTarget.disabled = false
    this.submitTarget.innerHTML = '<span>Go</span><svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clip-rule="evenodd"></path></svg>'
  }
}