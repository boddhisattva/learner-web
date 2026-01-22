import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navbar"
export default class extends Controller {
  static targets = [ "burger", "menu" ]

  toggle() {
    this.burgerTarget.classList.toggle("is-active")
    this.menuTarget.classList.toggle("is-active")
  }

  close() {
    this.burgerTarget.classList.remove("is-active")
    this.menuTarget.classList.remove("is-active")
  }
}
