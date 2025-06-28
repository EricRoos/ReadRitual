// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import PullToRefresh from "pulltorefreshjs"
import GoogleBooksAPI from "google_books_api"

window.GoogleBooksAPI = GoogleBooksAPI;

//checks for presence of a meta tag called native-app
function isNativeApp() {
  const metaTag = document.querySelector('meta[name="native-app"]');
  return metaTag !== null;
}

// Function to initialize PullToRefresh
function initializePullToRefresh() {
  if (isNativeApp()) { return; } // Skip if in native apply();

  // Destroy any existing PullToRefresh instance to prevent duplication
  PullToRefresh.destroyAll()

  // Initialize PullToRefresh
  PullToRefresh.init({
    mainElement: "body", // The element to attach the pull-to-refresh functionality
    onRefresh() {
      // Reload the page or perform any custom action
      location.reload()
    },
  })
}

// Initialize PullToRefresh on initial page load
initializePullToRefresh()

// Reinitialize PullToRefresh after Turbo renders new content
document.addEventListener("turbo:render", () => {
  initializePullToRefresh()
})
