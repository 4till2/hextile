import {Application} from "@hotwired/stimulus"
import LocalTime from "local-time"

LocalTime.start()
const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

export {application}
