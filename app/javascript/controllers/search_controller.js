import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["learningSearchInput", "clearButton"]
  static outlets = ["navbar"]

  connect() {
    // Show/hide clear button on page load based on input value
    this.toggleClearButton()
  }

  // Called when user types in the search field
  input() {
    this.toggleClearButton()

    // Auto-close mobile menu when searching
    if (this.hasNavbarOutlet) {
      this.navbarOutlet.close()
    }

    // Auto-submit the form as user types a character in the search input field
    this.learningSearchInputTarget.form.requestSubmit()
  }

  // This method clears the search input field and submits the form
  clear(event) {
    event.preventDefault()
    this.learningSearchInputTarget.value = ""
    this.toggleClearButton()
    // Submit to show all results
    this.learningSearchInputTarget.form.requestSubmit()
  }

  // Show/hide clear button based on whether input has a value
  toggleClearButton() {
    if (this.hasClearButtonTarget) {
      if (this.learningSearchInputTarget.value.length > 0) {
        this.clearButtonTarget.style.display = ''  // Remove inline style, show element
        this.clearButtonTarget.classList.remove('is-hidden')
      } else {
        this.clearButtonTarget.style.display = 'none'
        this.clearButtonTarget.classList.add('is-hidden')
      }
    }
  }
}
