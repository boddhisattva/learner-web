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
    clearTimeout(this.dismissTimeout)
    clearTimeout(this.animationTimeout)
  }

  dismiss() {
    this.element.style.transition = 'opacity 0.5s ease-out'
    this.element.style.opacity = '0'

    this.animationTimeout = setTimeout(() => {
      this.element.remove()
    }, this.animationDelayValue)
  }
}
