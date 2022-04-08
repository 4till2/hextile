import {Controller} from '@hotwired/stimulus'

export default class extends Controller {
    static get targets() {
        return ['self', 'background']
    }

    connect() {
        this.documentOverflowVal = document.body.style.overflow
        document.body.style.overflow = 'hidden'
    }

    disconnect(){
        document.body.style.overflow = this.documentOverflowVal
    }

    close(e) {
        e.preventDefault()
        this.selfTarget.remove()
    }

    closeWithBackground(e) {
        if (e.target === this.backgroundTarget) {
            this.close(e)
        }
    }

    closeWithKeyboard(e) {
        if (e.keyCode === 27) {
            this.close(e)
        }
    }
}