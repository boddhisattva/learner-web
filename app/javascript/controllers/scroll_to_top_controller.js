import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    console.log("Scrolling to top from scroll_to_top_controller.js");
    window.scrollTo({ top: 0, behavior: 'smooth' })
    this.element.remove()
  }
}
