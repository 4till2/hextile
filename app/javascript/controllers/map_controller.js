import {Controller} from "@hotwired/stimulus"

const MAPTILER_KEY = 'LiOgG1aQ5AphiucbQuRZ' // Key is domain restricted. https://cloud.maptiler.com/account/keys/
const MAP_URL = '/map.json'
let map = null
const leaflet = window.L


export default class extends Controller {

    connect() {
        map = this.mapInit()
    }

    async mapInit() {
        map = document.map
        if (map) return map

        leaflet.Map.addInitHook(function () {
            document.map = this
        });

        Promise.all([
            fetch(MAP_URL).then(l => l.json())
        ]).then(data => this.buildMap(data[0]))
    }

    buildMap(options) {
        let {overlays, zoom, center, bounds} = options

        map = leaflet.map('map', {
            center: center || [0, 0],
            zoom: zoom || 10,
            maxBounds: bounds ?
                leaflet.latLngBounds(
                    leaflet.latLng(bounds[0][0], bounds[0][1]),
                    leaflet.latLng(bounds[1][0], bounds[1][1]))
                : null,
            fullscreenControl: {
                pseudoFullscreen: false // if true, fullscreen to page width and height
            }
        });


        let baseLayers = this.add_tiles(map)

        let olays = this.create_overlay_groups(overlays)
        leaflet.control
            .layers(baseLayers, olays)
            .addTo(map);
        // TODO: Make generic by iterating and checking for option "default"
        olays['Mile Markers'].addTo(map);
    }

    add_tiles(map) {
        // Map tiles can be added, removed, or changed without consequence.
        let hextile_map = leaflet.mapboxGL({
            attribution: "\u003ca href=\"https://www.maptiler.com/copyright/\" target=\"_blank\"\u003e\u0026copy; MapTiler\u003c/a\u003e \u003ca href=\"https://www.openstreetmap.org/copyright\" target=\"_blank\"\u003e\u0026copy; OpenStreetMap contributors\u003c/a\u003e",
            style: `https://api.maptiler.com/maps/61255865-76da-477b-8c08-50b0aea648d4/style.json?key=${MAPTILER_KEY}`
        }).addTo(map)

        let satellite_map = leaflet.mapboxGL({
            attribution: "\u003ca href=\"https://www.maptiler.com/copyright/\" target=\"_blank\"\u003e\u0026copy; MapTiler\u003c/a\u003e \u003ca href=\"https://www.openstreetmap.org/copyright\" target=\"_blank\"\u003e\u0026copy; OpenStreetMap contributors\u003c/a\u003e",
            style: `https://api.maptiler.com/maps/hybrid/style.json?key=${MAPTILER_KEY}`
        })


        let raw_map = leaflet.mapboxGL({
            attribution: "\u003ca href=\"https://www.maptiler.com/copyright/\" target=\"_blank\"\u003e\u0026copy; MapTiler\u003c/a\u003e \u003ca href=\"https://www.openstreetmap.org/copyright\" target=\"_blank\"\u003e\u0026copy; OpenStreetMap contributors\u003c/a\u003e",
            style: `https://api.maptiler.com/maps/0acc1418-8632-4009-97a0-66c02ac92f23/style.json?key=${MAPTILER_KEY}`
        })

        // The tile options. The last one is default.
        return {
            "Raw": raw_map,
            "Satellite": satellite_map,
            "Hextile": hextile_map
        }
    }

    create_overlay_groups(overlays) {
        let result = {}
        overlays.forEach((overlay) => {
                result[overlay.name] = leaflet.layerGroup(this.create_overlay(overlay))
            }
        )
        return result
    }

    create_overlay(overlay) {
        return overlay.items.map(item => {
            if (overlay.type === 'Marker') {
                return this.create_marker(item)
            } else if (overlay.type === 'GeoJson') {
                return this.create_geoJson(item)
            }
        })
    }

    create_marker(marker) {
        let m = leaflet.marker([marker.lat, marker.lng], {
            riseOnHover: true,
            icon: leaflet.divIcon({
                className: `${marker?.properties?.className} bg-black opacity-50`
            }),
        })
        if (marker?.properties?.tooltip) m.bindTooltip(marker?.properties?.tooltip).openTooltip()
        if (marker?.properties?.popup) m.bindPopup(marker?.properties?.popup).openPopup();
        return m
    }

    create_geoJson(geo) {
        return (
            leaflet.geoJSON(geo, {...geo.options}
            )
        )
    }

}
