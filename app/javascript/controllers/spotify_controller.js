import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  static targets = ['spinner'];

  syncArtists() {
    const button = this.element;
    const spinner = this.spinnerTarget;

    // Show the spinner
    spinner.classList.remove('hidden');

    // Disable the button while loading the page
    button.disabled = true;

    const csrfToken = document.querySelector("meta[name=csrf-token]").getAttribute("content");

    fetch('/sync_spotify_followed_artists', {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Content-Type': 'application/json'
      }
    }).then(response => {
      if (response.ok) {
        // Load the page once the job is done
        Turbo.visit(window.location.href);
      }
    }).finally(()=> {
      // Cacher le spinner et réactiver le bouton une fois que le chargement est terminé
      spinner.classList.add('hidden');
      button.disabled = false;
    });
  }
}
