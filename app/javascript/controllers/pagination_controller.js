import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pagination"
export default class extends Controller {

  connect() {
    document.addEventListener("keydown", this.handleKeyDown.bind(this));
  }

  handleKeyDown(event) {
    switch(event.key) {
      case "ArrowLeft":
        this.loadPreviousPage();
        break;
      case "ArrowRight":
        this.loadNextPage();
        break;
    }
  }

  loadPreviousPage() {
    const previousPageLink = this.element.querySelector(".prev").children[0];
    if (previousPageLink) { Turbo.visit(previousPageLink.href); }
  }

  loadNextPage() {
    const nextPageLink = this.element.querySelector(".next").children[0];
    if (nextPageLink) { Turbo.visit(nextPageLink.href); }
  }


}
