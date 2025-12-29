import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Auto-dismiss after 4 seconds
    this.dismissTimeout = setTimeout(() => {
      this.dismiss()
    }, 4000)
  }

  disconnect() {
    // Clear timeout if element is removed before auto-dismiss
    if (this.dismissTimeout) {
      clearTimeout(this.dismissTimeout)
    }
  }

  dismiss() {
    // Fade out animation
    this.element.style.transition = 'opacity 0.5s ease-out'
    this.element.style.opacity = '0'

    // Remove from DOM after fade out
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
}
