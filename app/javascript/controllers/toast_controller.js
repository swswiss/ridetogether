// app/javascript/controllers/toast_controller.js
//
// Controller Stimulus pentru notificări (toast) în colțul dreapta-sus.
// Apare cu animație, dispare singur după cateva secunde, sau la click pe X.

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    // durata (ms) după care dispare singur; 0 = nu dispare automat
    delay: { type: Number, default: 4000 }
  }

  connect() {
    // animație de intrare (alunecă din dreapta + fade in)
    requestAnimationFrame(() => {
      this.element.classList.add("toast--visible")
    })

    // programează dispariția automată
    if (this.delayValue > 0) {
      this.timeout = setTimeout(() => this.dismiss(), this.delayValue)
    }
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  // apelat de butonul X sau automat
  dismiss() {
    if (this.timeout) clearTimeout(this.timeout)
    // animație de ieșire
    this.element.classList.remove("toast--visible")
    this.element.classList.add("toast--leaving")
    // scoate din DOM după ce se termină tranziția
    this.element.addEventListener("transitionend", () => {
      this.element.remove()
    }, { once: true })
  }

  // pune pe pauză auto-dismiss cand treci cu mouse-ul peste
  pause() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  // reia auto-dismiss cand pleci cu mouse-ul
  resume() {
    if (this.delayValue > 0) {
      this.timeout = setTimeout(() => this.dismiss(), this.delayValue)
    }
  }
}
