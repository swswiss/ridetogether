// ═══════════════════════════════════════════════════════
// UPLOAD — acum trimite și resource_type (image/video)
// app/javascript/controllers/gallery_upload_controller.js
// ═══════════════════════════════════════════════════════
//
// Diferența față de versiunea anterioară:
//  - endpoint-ul Cloudinary se alege după tip (image vs video)
//  - trimitem resource_type la server când salvăm

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "progress"]
  static values = { signatureUrl: String, createUrl: String }

  open() { this.inputTarget.click() }

  async upload() {
    const files = Array.from(this.inputTarget.files)
    if (files.length === 0) return
    files.forEach((file) => this.uploadOne(file))
    this.inputTarget.value = ""
  }

  async uploadOne(file) {
    const isVideo = file.type.startsWith("video/")
    const row = this.addProgressRow(file.name)

    try {
      const sig = await this.fetchSignature()

      const form = new FormData()
      form.append("file", file)
      form.append("api_key", sig.api_key)
      form.append("timestamp", sig.timestamp)
      form.append("signature", sig.signature)
      form.append("folder", sig.folder)

      const result = await this.sendToCloudinary(sig.cloud_name, form, row, isVideo)
      await this.savePhoto(result, isVideo ? "video" : "image")

      row.remove()
    } catch (e) {
      this.markError(row, e.message)
    }
  }

  fetchSignature() {
    return fetch(this.signatureUrlValue, { headers: { "Accept": "application/json" } })
      .then((r) => {
        if (!r.ok) return r.json().then((j) => { throw new Error(j.error || "Eroare semnătură") })
        return r.json()
      })
  }

  // endpoint Cloudinary diferă: /image/upload vs /video/upload
  sendToCloudinary(cloudName, form, row, isVideo) {
    const kind = isVideo ? "video" : "image"
    const url = `https://api.cloudinary.com/v1_1/${cloudName}/${kind}/upload`
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest()
      xhr.open("POST", url)
      xhr.upload.addEventListener("progress", (e) => {
        if (e.lengthComputable) this.setProgress(row, Math.round((e.loaded / e.total) * 100))
      })
      xhr.addEventListener("load", () => {
        if (xhr.status >= 200 && xhr.status < 300) resolve(JSON.parse(xhr.responseText))
        else reject(new Error("Upload eșuat"))
      })
      xhr.addEventListener("error", () => reject(new Error("Eroare de rețea")))
      xhr.send(form)
    })
  }

  savePhoto(result, resourceType) {
    const body = new FormData()
    body.append("event_photo[cloudinary_public_id]", result.public_id)
    body.append("event_photo[width]", result.width || "")
    body.append("event_photo[height]", result.height || "")
    body.append("event_photo[resource_type]", resourceType)

    return fetch(this.createUrlValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: body
    }).then((r) => {
      if (!r.ok) throw new Error("Nu am putut salva")
      return r.text()
    }).then((html) => Turbo.renderStreamMessage(html))
  }

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
