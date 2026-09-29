// ═══════════════════════════════════════════════════════
// LIGHTBOX — mărește poza/video la click
// app/javascript/controllers/lightbox_controller.js
// ═══════════════════════════════════════════════════════
//
// Deschide un overlay cu poza/video-ul mare. Navigare prev/next, închidere
// cu X / click pe fundal / tasta Escape.

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "content"]

  connect() {
    this.index = 0
    this._keyHandler = (e) => {
      if (!this.overlayTarget.classList.contains("open")) return
      if (e.key === "Escape") this.close()
      if (e.key === "ArrowLeft") this.prev()
      if (e.key === "ArrowRight") this.next()
    }
    document.addEventListener("keydown", this._keyHandler)
  }

  disconnect() {
    document.removeEventListener("keydown", this._keyHandler)
  }

  // toate item-urile din grilă (pentru navigare)
  items() {
    return Array.from(this.element.querySelectorAll(".g-item"))
  }

  open(event) {
    const item = event.currentTarget
    this.index = this.items().indexOf(item)
    this.show(item)
    this.overlayTarget.classList.add("open")
    document.body.style.overflow = "hidden"   // blochează scroll-ul în spate
  }

  show(item) {
    const type = item.dataset.lightboxType
    const src = item.dataset.lightboxSrc

    if (type === "video") {
      this.contentTarget.innerHTML =
        `<video src="${src}" controls autoplay playsinline></video>`
    } else {
      this.contentTarget.innerHTML =
        `<img src="${src}" alt="">`
    }
  }

  next() {
    const items = this.items()
    if (items.length === 0) return
    this.index = (this.index + 1) % items.length
    this.show(items[this.index])
  }

  prev() {
    const items = this.items()
    if (items.length === 0) return
    this.index = (this.index - 1 + items.length) % items.length
    this.show(items[this.index])
  }

  close() {
    this.overlayTarget.classList.remove("open")
    this.contentTarget.innerHTML = ""   // oprește video-ul
    document.body.style.overflow = ""
  }

  // închide doar dacă dai click pe fundal (nu pe imagine/butoane)
  backdrop(event) {
    if (event.target === this.overlayTarget) this.close()
  }

  // oprește propagarea (ca butonul de ștergere să nu deschidă lightbox-ul)
  stop(event) {
    event.stopPropagation()
  }
}
