// app/javascript/controllers/route_draw_controller.js
//
// Desenează un traseu liber pe hartă (Leaflet + Leaflet.draw).
// - dai click pe hartă → pui puncte → se trage o linie
// - calculează distanța totală în timp real
// - pune coordonatele (JSON) + distanța în câmpuri hidden ale formularului
//
// HTML așteptat (vezi new.html.erb):
//   data-controller="route-draw"
//   data-route-draw-target="map"          → div-ul hărții
//   data-route-draw-target="coordinates"  → input hidden pt coordonate
//   data-route-draw-target="distance"     → input hidden pt distanță
//   data-route-draw-target="distanceLabel"→ span care afișează distanța userului

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["map", "coordinates", "distance", "distanceLabel"]

  connect() {
    // 1. inițializează harta, centrată pe Iași (schimbă coordonatele dacă vrei alt oraș)
    this.map = L.map(this.mapTarget).setView([47.1585, 27.6014], 13)

    // 2. adaugă dalele OpenStreetMap (gratuite, fără cheie)
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: "© OpenStreetMap"
    }).addTo(this.map)

    // 3. strat unde stau formele desenate
    this.drawnItems = new L.FeatureGroup()
    this.map.addLayer(this.drawnItems)

    // 4. unealta de desenat: DOAR polyline (linie/traseu), nimic altceva
    this.drawControl = new L.Control.Draw({
      draw: {
        polyline: { shapeOptions: { color: "#e5533d", weight: 4 } },
        polygon: false, rectangle: false, circle: false,
        marker: false, circlemarker: false
      },
      edit: { featureGroup: this.drawnItems, remove: true }
    })
    this.map.addControl(this.drawControl)

    // 5. când desenezi o linie → o salvăm și calculăm
    this.map.on(L.Draw.Event.CREATED, (e) => {
      // permitem un singur traseu: ștergem ce era înainte
      this.drawnItems.clearLayers()
      this.drawnItems.addLayer(e.layer)
      this.updateFromLayer(e.layer)
    })

    // când editezi (muți puncte) → recalculează
    this.map.on(L.Draw.Event.EDITED, (e) => {
      e.layers.eachLayer((layer) => this.updateFromLayer(layer))
    })

    // când ștergi traseul → golește câmpurile
    this.map.on(L.Draw.Event.DELETED, () => {
      this.coordinatesTarget.value = ""
      this.distanceTarget.value = ""
      this.distanceLabelTarget.textContent = "0 km"
    })
  }

  // ia linia desenată → extrage coordonatele + calculează distanța
  updateFromLayer(layer) {
    const latlngs = layer.getLatLngs()

    // coordonatele ca array [[lat, lng], ...]
    const coords = latlngs.map((p) => [p.lat, p.lng])
    this.coordinatesTarget.value = JSON.stringify(coords)

    // distanța totală = suma segmentelor (Leaflet o dă în metri)
    let meters = 0
    for (let i = 1; i < latlngs.length; i++) {
      meters += latlngs[i - 1].distanceTo(latlngs[i])
    }
    const km = (meters / 1000).toFixed(1)

    this.distanceTarget.value = km
    this.distanceLabelTarget.textContent = `${km} km`
  }

  disconnect() {
    if (this.map) this.map.remove()
  }
}
