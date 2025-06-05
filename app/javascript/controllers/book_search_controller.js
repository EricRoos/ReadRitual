import { Controller } from "@hotwired/stimulus"
import GoogleBooksAPI from "google_books_api"

// Connects to data-controller="book-search"
export default class extends Controller {
  static targets = ["input", "resultsTemplate", "resultsContainer"]

  connect() {
    this.api = new GoogleBooksAPI("") // Replace with your actual API key
    this.debounceTimer = null // Timer for debouncing
    console.log("BookSearchController connected")
  }

  search(event) {
    event.preventDefault()
    const query = this.inputTarget.value.trim()

    // Clear the previous timer
    clearTimeout(this.debounceTimer)

    // Set a new timer to debounce the search
    this.debounceTimer = setTimeout(() => {
      if (query.length > 0) {
        this.api.searchBooks(query)
          .then(results => {
            // create a new HTML element from the template
            const template = document.createElement("template");
            template.innerHTML = this.resultsTemplateTarget.innerHTML.trim();
            const resultsContainer = this.resultsContainerTarget;
            resultsContainer.innerHTML = ""; // Clear previous results
            console.log("Search results:", results)
            results.forEach(book => {
              const resultElement = template.content.cloneNode(true);
              resultElement.querySelector(".book-title").textContent = book.title;
              resultElement.querySelector(".book-authors").textContent = book.authors.join(", ");
              if (book.thumbnail) {
                resultElement.querySelector(".book-thumbnail").src = book.thumbnail;
              } else {
                resultElement.querySelector(".book-thumbnail").remove();
              }
              resultElement.querySelector(".new-book-title").value = book.title; // Store the book ID in a hidden input
              resultElement.querySelector(".new-book-author").value = book.authors.join(", "); // Store the book ID in a hidden input
              resultsContainer.appendChild(resultElement);
            });
          })
          .catch(error => {
            console.error("Error searching books:", error)
          })
      }
    }, 300) // Debounce delay in milliseconds
  }
}
