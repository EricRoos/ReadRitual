import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clipboard"
export default class extends Controller {
  static targets = ["field"]

  async paste() {
    try {
      // Read text from clipboard directly
      let clipboardText = await navigator.clipboard.readText();
      if (!clipboardText) {
        clipboardText = await navigator.clipboard.read();
        if (clipboardText.length === 0 || !clipboardText[0].types.includes("text/plain")) {
          clipboardText = "";
        } else {
          clipboardText = await clipboardText[0].getType("text/plain").then(blob => blob.text());
        }
      }

      if (!clipboardText) {
        alert("Clipboard is empty or does not contain text.");
        return;
      }

      this.fieldTarget.value = clipboardText;
      const acceptedHosts = ["www.audible.com"];
      const url = new URL(clipboardText);
      console.log(url.hostname);
      if (!acceptedHosts.includes(url.hostname)) {
        alert("The URL must be from www.audible.com");
        return;
      }
      this.element.requestSubmit(); // Submit the form if needed
    } catch (error) {
      console.error("Failed to paste URL from clipboard:", error);
      alert(`Failed to paste URL from clipboard: ${error.message}`);
    }
  }
}
