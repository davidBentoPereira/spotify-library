import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pagination"
export default class extends Controller {

  connect() {
    document.addEventListener("keydown", this.handleKeyDown.bind(this));
  }

  handleKeyDown(event) {
    if (event.metaKey || event.ctrlKey) { // Check if key CMD or CTRL is pressed
      switch(event.key) {
        case "ArrowLeft":
          event.preventDefault();
          this.loadFirstPage();
          break;
        case "ArrowRight":
          event.preventDefault();
          this.loadLastPage();
          break;
      }
    } else {
      switch(event.key) {
        case "ArrowLeft":
          this.loadPreviousPage();
          break;
        case "ArrowRight":
          this.loadNextPage();
          break;
      }
    }
  }

  loadFirstPage() {
    const firstPageLink = this.element.querySelector(".first");
    if (firstPageLink) { Turbo.visit(firstPageLink.href); }
  }

  loadLastPage() {
    const lastPageLink = this.element.querySelector(".last");
    if (lastPageLink) { Turbo.visit(lastPageLink.href); }
  }

  loadPreviousPage() {
    const previousPageLink = this.element.querySelector(".prev");
    if (previousPageLink) { Turbo.visit(previousPageLink.href); }
  }

  loadNextPage() {
    const nextPageLink = this.element.querySelector(".next");
    if (nextPageLink) { Turbo.visit(nextPageLink.href); }
  }
}
