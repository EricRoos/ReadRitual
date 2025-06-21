import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-submit"
export default class extends Controller {
  static targets = ["input", "form"]

  connect() {
    console.log("AutoSubmitController connected")
  }

  submit() {
    if (this.inputTarget.files.length > 0) {
      this.formTarget.requestSubmit();
    }
  }
}