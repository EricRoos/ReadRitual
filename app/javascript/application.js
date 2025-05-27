// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import PullToRefresh from "pulltorefreshjs"

// Function to initialize PullToRefresh
function initializePullToRefresh() {
  PullToRefresh.init({
    mainElement: "main", // The element to attach the pull-to-refresh functionality
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
