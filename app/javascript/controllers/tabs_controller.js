import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab"]

  select(event) {
    this.tabTargets.forEach((tab) => {
      tab.classList.remove("active")
    })

    event.currentTarget.classList.add("active")
  }
}