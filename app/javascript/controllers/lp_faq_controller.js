import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  toggle(event) {
    const item = event.currentTarget.closest("[data-lp-faq-target='item']")
    const wasOpen = item.classList.contains("lp-open")
    this.itemTargets.forEach(i => i.classList.remove("lp-open"))
    if (!wasOpen) item.classList.add("lp-open")
  }
}
