import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    duration: { type: Number, default: 4000 },
    animationDelay: { type: Number, default: 500 }
  }

  connect() {
    this.dismissTimeout = setTimeout(() => {
      this.dismiss()
    }, this.durationValue)
  }

  disconnect() {
    if (this.dismissTimeout) {
      clearTimeout(this.dismissTimeout)
    }
  }

  dismiss() {
    this.element.style.transition = 'opacity 0.5s ease-out'
    this.element.style.opacity = '0'

    setTimeout(() => {
      this.element.remove()
    }, this.animationDelayValue)
  }
}
