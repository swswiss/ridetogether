// app/javascript/controllers/event_form_controller.js
//
// Gestionează chip-urile de tip și radio-urile de regim din formularul de tură.
// Pune valoarea aleasă în câmpurile hidden (ride_type, regime).

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["chip", "rideType", "regime", "regimeInput"]

  // click pe un chip de tip (MTB, Cursieră...)
  selectType(event) {
    const chip = event.currentTarget
    this.chipTargets.forEach((c) => c.classList.remove("selected"))
    chip.classList.add("selected")
    this.rideTypeTarget.value = chip.dataset.value
  }

  // click pe un radio de regim (no_drop / drop)
  selectRegime(event) {
    const radio = event.currentTarget
    this.regimeTargets.forEach((r) => r.classList.remove("selected"))
    radio.classList.add("selected")
    this.regimeInputTarget.value = radio.dataset.value
  }
}
