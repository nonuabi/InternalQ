import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.onScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })
    this.handleScroll()
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }

  handleScroll() {
    this.element.classList.toggle("lp-scrolled", window.scrollY > 8)
  }
}
