import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tag"
export default class extends Controller {
  static targets = ["panel", "deleteLink"]

  connect() {
    this.closePanelOnClickOutside();
  }

  togglePanel() {
    if (this.panelTarget.classList.contains("hidden") === true) {
      console.log("Open Panel")
      this.open(this.panelTarget);
    } else {
      this.close(this.panelTarget);
    }
  }

  close(element) { element.classList.add("hidden");}
  open(element) { element.classList.remove("hidden"); }

  closePanelOnClickOutside(cb) {
    const panelBackground = document.getElementById("panel-background")
    const panel = document.getElementById("panel")

    document.addEventListener('click', event => {
      if (panelBackground.contains(event.target) && !panel.contains(event.target)) {
        this.togglePanel()
      };
    });
  };

}
