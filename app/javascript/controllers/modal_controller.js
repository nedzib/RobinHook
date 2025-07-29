import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  // Abre el modal
  open(event) {
    event?.preventDefault()
    this.modalTarget.classList.remove('hidden')
    this.updateCurrentUserField()
  }

  // Cierra el modal
  close(event) {
    event?.preventDefault()
    this.modalTarget.classList.add('hidden')
  }

  // Cierra el modal si se hace clic en el fondo
  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  // Cierra el modal con la tecla Escape
  closeOnEscape(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }

  connect() {
    // Agregar listener para cerrar con Escape
    this.boundCloseOnEscape = this.closeOnEscape.bind(this)
    document.addEventListener('keydown', this.boundCloseOnEscape)
  }

  disconnect() {
    // Remover listener al desconectar
    document.removeEventListener('keydown', this.boundCloseOnEscape)
  }

  // Actualiza el campo de usuario actual en el formulario del modal
  updateCurrentUserField() {
    const currentUser = localStorage.getItem('currentParticipantName')
    if (currentUser) {
      const hiddenField = this.modalTarget.querySelector('[id^="current_user_name_"]')
      if (hiddenField) {
        hiddenField.value = currentUser
      }
    }
  }
}
