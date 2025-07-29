import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Abre un modal específico por su ID
  open(event) {
    event?.preventDefault()
    
    const target = event.currentTarget.dataset.modalTarget
    if (target) {
      const modal = document.querySelector(target)
      if (modal) {
        modal.classList.remove('hidden')
        this.updateCurrentUserField(modal)
      }
    }
  }

  // Cierra un modal específico
  close(event) {
    event?.preventDefault()
    
    const modal = event.currentTarget.closest('.sampling-modal')
    if (modal) {
      modal.classList.add('hidden')
    }
  }

  // Cierra el modal si se hace clic en el fondo
  closeOnBackdrop(event) {
    if (event.target.classList.contains('sampling-modal')) {
      event.target.classList.add('hidden')
    }
  }

  // Actualiza el campo de usuario actual en el formulario del modal
  updateCurrentUserField(modal) {
    const currentUser = localStorage.getItem('currentParticipantName')
    if (currentUser) {
      const hiddenField = modal.querySelector('[id^="current_user_name_"]')
      if (hiddenField) {
        hiddenField.value = currentUser
      }
    }
  }

  // Cierra modales con la tecla Escape
  handleKeydown(event) {
    if (event.key === 'Escape') {
      document.querySelectorAll('.sampling-modal:not(.hidden)').forEach(modal => {
        modal.classList.add('hidden')
      })
    }
  }

  connect() {
    // Agregar listener global para Escape
    document.addEventListener('keydown', this.handleKeydown.bind(this))
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleKeydown.bind(this))
  }
}
