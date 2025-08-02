import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Abre un modal específico por su ID
  open(event) {
    event?.preventDefault()

    const target = event.currentTarget.dataset.modalTarget
    if (target) {
      // Verificar si es un modal de muestreo (sampling)
      if (target.includes('samplingModal') || target.includes('globalSamplingModal')) {
        const currentUser = localStorage.getItem('currentParticipantName')
        if (!currentUser) {
          this.showUserSelectionAlert(target)
          return
        }
      }

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
    const hiddenField = modal.querySelector('[id^="current_user_name_"]')
    if (hiddenField) {
      // Si hay usuario seleccionado, usar ese. Si no, dejar vacío (permitir continuar sin seleccionar)
      hiddenField.value = currentUser || ""
    }
  }

  // Cierra modales con la tecla Escape
  handleKeydown(event) {
    if (event.key === 'Escape') {
      document.querySelectorAll('.sampling-modal:not(.hidden)').forEach(modal => {
        modal.classList.add('hidden')
      })

      // También cerrar alerta personalizada si está abierta
      const customAlert = document.querySelector('#customAlert')
      if (customAlert && !customAlert.classList.contains('hidden')) {
        customAlert.classList.add('hidden')
      }
    }
  }

  // Muestra una alerta personalizada cuando no hay usuario seleccionado
  showUserSelectionAlert(modalTarget) {
    // Obtener la alerta que ya está en el DOM
    const alertModal = document.querySelector('#customAlert')
    
    if (!alertModal) {
      console.error('Modal de alerta no encontrado en el DOM')
      return
    }

    // Limpiar event listeners existentes para evitar duplicados
    const alertCancel = alertModal.querySelector('#alertCancel')
    const alertContinue = alertModal.querySelector('#alertContinue')

    // Clonar nodos para eliminar event listeners existentes
    const newAlertCancel = alertCancel.cloneNode(true)
    const newAlertContinue = alertContinue.cloneNode(true)

    alertCancel.parentNode.replaceChild(newAlertCancel, alertCancel)
    alertContinue.parentNode.replaceChild(newAlertContinue, alertContinue)

    // Event listeners para los botones
    newAlertCancel.addEventListener('click', () => {
      alertModal.classList.add('hidden')
    })

    newAlertContinue.addEventListener('click', () => {
      alertModal.classList.add('hidden')

      // Usar un pequeño delay para asegurar que el modal anterior se cierre completamente
      setTimeout(() => {
        // Continuar con la apertura del modal original usando el target guardado
        const modal = document.querySelector(modalTarget)
        if (modal) {
          modal.classList.remove('hidden')
          this.updateCurrentUserField(modal)

          // Forzar focus en el primer input del modal para mejor UX
          setTimeout(() => {
            const firstInput = modal.querySelector('input[type="url"], input[type="text"], textarea')
            if (firstInput) {
              firstInput.focus()
            }
          }, 100)
        } else {
          console.error('Modal no encontrado:', modalTarget)
        }
      }, 150)
    })

    // Cerrar al hacer clic en el fondo (recrear listener)
    alertModal.onclick = (e) => {
      if (e.target === alertModal) {
        alertModal.classList.add('hidden')
      }
    }

    // Mostrar la alerta
    alertModal.classList.remove('hidden')
  }

  connect() {
    // Agregar listener global para Escape
    document.addEventListener('keydown', this.handleKeydown.bind(this))
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleKeydown.bind(this))
  }
}
