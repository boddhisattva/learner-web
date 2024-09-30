import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navbar"
export default class extends Controller {
  static targets = [ "burger", "menu" ]

  console.log("I am in the navbar controller");

  debugger;

  toggle() {
    console.log("I am in the toggle method of navbar controller")

    this.burgerTarget.classList.toggle("is-active")
    this.menuTarget.classList.toggle("is-active")
  }
}
