import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["learning_search_input"]

  // This method clears the search input field
  clear() {
    this.inputTarget.value = ""
  }
}
