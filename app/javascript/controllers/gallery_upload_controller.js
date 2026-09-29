// ═══════════════════════════════════════════════════════
// PASUL 9 — Stimulus: upload direct din browser
// app/javascript/controllers/gallery_upload_controller.js
// ═══════════════════════════════════════════════════════
//
// Flux:
//  1. userul alege poze (input file, multiple)
//  2. pt fiecare poză: cere semnătura serverului
//  3. trimite poza DIRECT la Cloudinary (cu progres)
//  4. după ce Cloudinary răspunde, trimite public_id serverului (care salvează + Turbo Stream)
//
// HTML așteptat (vezi index view):
//   data-controller="gallery-upload"
//   data-gallery-upload-signature-url-value="..."   (endpoint semnătură)
//   data-gallery-upload-create-url-value="..."       (endpoint salvare)
//   data-gallery-upload-target="input"    (input file)
//   data-gallery-upload-target="progress" (zona de progres)

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "progress"]
  static values = { signatureUrl: String, createUrl: String }

  open() {
    this.inputTarget.click()
  }

  async upload() {
    const files = Array.from(this.inputTarget.files)
    if (files.length === 0) return

    // încarcă fiecare poză în paralel
    files.forEach((file) => this.uploadOne(file))

    // golește input-ul ca să poți re-alege aceleași fișiere data viitoare
    this.inputTarget.value = ""
  }

  async uploadOne(file) {
    const row = this.addProgressRow(file.name)

    try {
      // 1. cere semnătura de la server
      const sig = await this.fetchSignature()

      // 2. construiește form-data pt Cloudinary
      const form = new FormData()
      form.append("file", file)
      form.append("api_key", sig.api_key)
      form.append("timestamp", sig.timestamp)
      form.append("signature", sig.signature)
      form.append("folder", sig.folder)

      // 3. trimite DIRECT la Cloudinary, cu progres
      const result = await this.sendToCloudinary(sig.cloud_name, form, row)

      // 4. trimite public_id serverului → salvează EventPhoto + Turbo Stream
      await this.savePhoto(result)

      row.remove()   // gata, poza apare în galerie prin Turbo Stream
    } catch (e) {
      this.markError(row, e.message)
    }
  }

  fetchSignature() {
    return fetch(this.signatureUrlValue, {
      headers: { "Accept": "application/json" }
    }).then((r) => {
      if (!r.ok) throw new Error("Nu am putut obține semnătura")
      return r.json()
    })
  }

  // upload cu XMLHttpRequest ca să avem eveniment de progres
  sendToCloudinary(cloudName, form, row) {
    const url = `https://api.cloudinary.com/v1_1/${cloudName}/image/upload`
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest()
      xhr.open("POST", url)

      xhr.upload.addEventListener("progress", (e) => {
        if (e.lengthComputable) {
          const pct = Math.round((e.loaded / e.total) * 100)
          this.setProgress(row, pct)
        }
      })

      xhr.addEventListener("load", () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          resolve(JSON.parse(xhr.responseText))
        } else {
          reject(new Error("Upload eșuat la Cloudinary"))
        }
      })
      xhr.addEventListener("error", () => reject(new Error("Eroare de rețea")))
      xhr.send(form)
    })
  }

  // trimite referința la server (POST create) — răspuns Turbo Stream
  savePhoto(cloudinaryResult) {
    const body = new FormData()
    body.append("event_photo[cloudinary_public_id]", cloudinaryResult.public_id)
    body.append("event_photo[width]", cloudinaryResult.width)
    body.append("event_photo[height]", cloudinaryResult.height)

    return fetch(this.createUrlValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: body
    }).then((r) => {
      if (!r.ok) throw new Error("Nu am putut salva poza")
      return r.text()
    }).then((html) => {
      // aplică Turbo Stream-ul primit (adaugă poza în galerie)
      Turbo.renderStreamMessage(html)
    })
  }

  // ── UI progres ──
  addProgressRow(name) {
    const row = document.createElement("div")
    row.className = "up-row"
    row.innerHTML = `<span class="up-name">${name}</span><span class="up-bar"><span class="up-fill"></span></span><span class="up-pct">0%</span>`
    this.progressTarget.appendChild(row)
    return row
  }
  setProgress(row, pct) {
    row.querySelector(".up-fill").style.width = pct + "%"
    row.querySelector(".up-pct").textContent = pct + "%"
  }
  markError(row, msg) {
    row.querySelector(".up-pct").textContent = "eroare"
    row.classList.add("up-error")
  }
}
