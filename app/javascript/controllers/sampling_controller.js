import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  // Cierra todos los modales de muestreo
  closeAll() {
    document.querySelectorAll('.sampling-modal').forEach(modal => {
      modal.classList.add('hidden')
    })
  }

  // Maneja respuestas exitosas de formularios de muestreo
  handleSuccess(event) {
    // Cerrar todos los modales
    this.closeAll()
    
    // Si hay un mensaje en el detail del evento, mostrarlo
    if (event.detail && event.detail.message) {
      this.showNotification(event.detail.message, 'success')
    }
  }

  // Maneja errores de formularios de muestreo
  handleError(event) {
    // Si hay un mensaje de error, mostrarlo
    if (event.detail && event.detail.message) {
      this.showNotification(event.detail.message, 'error')
    }
  }

  connect() {
    // Escuchar eventos de turbo para formularios de muestreo
    this.element.addEventListener('turbo:submit-end', this.handleSubmitEnd.bind(this))
  }

  disconnect() {
    this.element.removeEventListener('turbo:submit-end', this.handleSubmitEnd.bind(this))
  }

  handleSubmitEnd(event) {
    const form = event.target
    if (form && form.closest('.sampling-modal')) {
      // Es un formulario de muestreo, cerrar el modal
      this.closeAll()
    }
  }

  // Muestra una notificación
  showNotification(message, type = 'success') {
    // Usar el controlador de notificaciones si está disponible
    if (window.NotificationController) {
      window.NotificationController.show(message, type)
    } else {
      // Fallback a alert
      alert(message)
    }
  }
}
