import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "destination"]

  clear() {
    if (this.hasContainerTarget) {
      this.containerTarget.innerHTML = ''
    }

    if (this.hasDestinationTarget) {
      this.destinationTarget.scrollIntoView({
        behavior: 'smooth',
        block: 'center'
      })
    }
  }
}
