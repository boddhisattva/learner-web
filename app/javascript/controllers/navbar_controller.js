import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navbar"
export default class extends Controller {
  static targets = [ "burger", "menu" ]

  connect() {
    console.log('Hello from Stimulus', this.element);
  }


  toggle() {
    this.burgerTarget.classList.toggle("is-active")
    this.menuTarget.classList.toggle("is-active")
  }
}
