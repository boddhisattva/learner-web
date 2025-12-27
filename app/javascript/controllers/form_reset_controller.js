import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  clear() {
    // Find the parent container that holds the form (the #new_learning_form div)
    const formContainer = document.getElementById('new_learning_form')

    // Find the "New Learning" button to scroll to it
    const newLearningButton = document.getElementById('new_learning_button')

    if (formContainer) {
      formContainer.innerHTML = ''
    }

    // Scroll smoothly to the "New Learning" button
    // This puts focus back where the user started, without scrolling past lazy-loaded content
    if (newLearningButton) {
      newLearningButton.scrollIntoView({
        behavior: 'smooth',
        block: 'center'
      })
    }
  }
}
