# Pin npm packages by running ./bin/importmap

pin "application"
pin "google_books_api"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "pulltorefreshjs" # @0.1.22
