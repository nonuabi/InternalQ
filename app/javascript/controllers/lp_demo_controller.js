import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { active: { type: Number, default: 0 } }

  connect() {
    // Show the first panel and trigger typing animation after a short delay
    this.show(this.activeValue, true)
  }

  switch(event) {
    const index = parseInt(event.currentTarget.dataset.index, 10)
    if (index === this.activeValue) return
    this.activeValue = index
    this.show(index, true)
  }

  show(index, animate = false) {
    this.tabTargets.forEach((tab, i) => {
      tab.classList.toggle("lp-active", i === index)
      tab.setAttribute("aria-selected", i === index)
    })

    this.panelTargets.forEach((panel, i) => {
      panel.classList.toggle("lp-active", i === index)
      // Reset typing state on all panels
      panel.classList.remove("lp-thread-typed")
    })

    if (!animate) return

    const panel = this.panelTargets[index]
    if (!panel) return

    clearTimeout(this.typingTimer)
    this.typingTimer = setTimeout(() => {
      panel.classList.add("lp-thread-typed")
    }, 700)
  }

  disconnect() {
    clearTimeout(this.typingTimer)
  }
}
