import {Controller} from '@hotwired/stimulus'

export default class extends Controller {
    static get targets() {
        return ['template']
    }

    open(e) {
        let template = this.templateTarget.content.cloneNode(true);
        document.body.appendChild(template);
    }
}