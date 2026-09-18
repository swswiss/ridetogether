// app/javascript/controllers/route_show_controller.js
//
// Randează un traseu SALVAT pe o hartă (read-only, fără desenare).
// Folosit pe pagina event (arată traseul turei) și în cardurile din „Turele mele".
//
// HTML așteptat:
//   data-controller="route-show"
//   data-route-show-coordinates-value="<%= route.coordinates.to_json %>"
//   (div-ul are id/height setate)

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { coordinates: Array }

  connect() {
    const coords = this.coordinatesValue
    if (!coords || coords.length < 2) return

    // harta read-only (fără zoom cu scroll, ca să nu deranjeze scroll-ul paginii)
    this.map = L.map(this.element, {
      scrollWheelZoom: false,
      dragging: true,
      zoomControl: true
    })

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: "© OpenStreetMap"
    }).addTo(this.map)

    // desenează linia salvată
    const line = L.polyline(coords, { color: "#e5533d", weight: 4 }).addTo(this.map)

    // marcaje start (negru) și final (portocaliu)
    L.circleMarker(coords[0], { radius: 6, color: "#1a1a1a", fillColor: "#1a1a1a", fillOpacity: 1 }).addTo(this.map)
    L.circleMarker(coords[coords.length - 1], { radius: 6, color: "#e5533d", fillColor: "#e5533d", fillOpacity: 1 }).addTo(this.map)

    // încadrează harta să vadă tot traseul
    this.map.fitBounds(line.getBounds(), { padding: [20, 20] })
  }

  disconnect() {
    if (this.map) this.map.remove()
  }
}
