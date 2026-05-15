import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["link"]
  static values = { sections: Array }

  connect() {
    this._sectionIds = this.linkTargets.map(a => a.getAttribute("href").replace("#", ""))
    this._observer = new IntersectionObserver(
      (entries) => {
        const visible = entries
          .filter(e => e.isIntersecting)
          .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top)
        if (visible[0]) this._setActive(visible[0].target.id)
      },
      { rootMargin: "-88px 0px -65% 0px", threshold: 0 }
    )
    this._sectionIds.forEach(id => {
      const el = document.getElementById(id)
      if (el) this._observer.observe(el)
    })
  }

  disconnect() {
    if (this._observer) this._observer.disconnect()
  }

  _setActive(id) {
    this.linkTargets.forEach(a => {
      a.classList.toggle("lp-toc-active", a.getAttribute("href") === "#" + id)
    })
  }
}
