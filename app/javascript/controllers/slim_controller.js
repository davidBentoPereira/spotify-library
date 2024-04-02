import { Controller } from "@hotwired/stimulus"
import SlimSelect from 'slim-select'

// Connects to data-controller="slim"
export default class extends Controller {
  connect() {
    new SlimSelect({
      select: this.element,
      settings: {
        closeOnSelect: false,
        hideSelected: true
      },
      events: {
        addable: function (value) {
          // return false or null if you do not want to allow value to be submitted
          if (value === 'bad') {return false}

          // Return the value string
          return value // Optional - value alteration // ex: value.toLowerCase()

          // Optional - Return a valid data object.
          // See methods/setData for list of valid options
          return {
            text: value,
            value: value.toLowerCase()
          }

          // Optional - Return a promise with either a string or data object
          return new Promise((resolve) => {
            resolve({
              text: value,
              value: value,
            })
          })
        }
      }
    })
  }
}
