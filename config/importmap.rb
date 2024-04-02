# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "slim-select", to: "https://ga.jspm.io/npm:slim-select@2.8.2/dist/slimselect.js"
pin "@stimulus-components/dialog", to: "https://ga.jspm.io/npm:@stimulus-components/dialog@1.0.1/dist/stimulus-dialog.mjs"
