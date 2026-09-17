// app/javascript/controllers/replies_controller.js
//
// Ascunde reply-urile unui post și le arată la click pe „Răspunde".
// Fiecare post are propriul controller, deci fiecare se deschide independent.

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "toggle"]

  connect() {
    // la încărcare, panoul e ascuns (începe closed)
    this.open = false
    this.update()
  }

  toggle() {
    this.open = !this.open
    this.update()
  }

  update() {
    // arată/ascunde panoul cu reply-uri + composer
    this.panelTarget.hidden = !this.open
  }
}
