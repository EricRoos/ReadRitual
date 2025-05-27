// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import PullToRefresh from "pulltorefreshjs"

// Configure PullToRefresh
PullToRefresh.init({
  mainElement: "main", // The element to attach the pull-to-refresh functionality
  onRefresh() {
    // Reload the page or perform any custom action
    location.reload()
  },
})
