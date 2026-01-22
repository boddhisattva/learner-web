import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  clear({ params }) {
    if (this.hasContainerTarget) {
      this.containerTarget.innerHTML = ''
    }

    const scrollTargetSelector = params.scrollTarget

    if (scrollTargetSelector) {
      const element = document.querySelector(scrollTargetSelector)

      if (element) {
        element.scrollIntoView({
          behavior: 'smooth',
          block: 'center'
        })
      }
    }
  }
}
