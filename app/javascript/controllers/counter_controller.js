import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value"]
  static values = { container: { type: String, default: "learning_page_1" } }

  connect() {
    this.setupMutationObserver()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  setupMutationObserver() {
    const container = document.getElementById(this.containerValue)
    if (!container) return

    this.observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach((node) => {
          if (node.nodeType === Node.ELEMENT_NODE && node.id && node.id.startsWith('learning_')) {
            this.increment()
          }
        })

        mutation.removedNodes.forEach((node) => {
          if (node.nodeType === Node.ELEMENT_NODE && node.id && node.id.startsWith('learning_')) {
            this.decrement()
          }
        })
      })
    })

    this.observer.observe(container, { childList: true })
  }

  increment() {
    const currentCount = this.getCurrentCount()
    this.updateCount(currentCount + 1)
  }

  decrement() {
    const currentCount = this.getCurrentCount()
    this.updateCount(Math.max(0, currentCount - 1))
  }

  getCurrentCount() {
    const text = this.valueTarget.textContent
    const match = text.match(/\d+/)
    return match ? parseInt(match[0], 10) : 0
  }

  updateCount(newCount) {
    const currentText = this.valueTarget.textContent
    // Replace the first number in the text (handles both "X total" and "X of Y total" formats)
    const updatedText = currentText.replace(/\d+/, newCount.toString())
    this.valueTarget.textContent = updatedText
  }
}
