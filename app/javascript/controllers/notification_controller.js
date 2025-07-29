import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    message: String,
    type: { type: String, default: "success" },
    duration: { type: Number, default: 3000 }
  }

  connect() {
    if (this.messageValue) {
      this.show()
    }
    
    // Escuchar eventos personalizados de notificación
    document.addEventListener('notification:show', this.handleNotificationEvent.bind(this))
  }

  disconnect() {
    document.removeEventListener('notification:show', this.handleNotificationEvent.bind(this))
  }

  show() {
    if (this.messageValue) {
      this.showNotification(this.messageValue, this.typeValue)
    }
  }

  handleNotificationEvent(event) {
    const { message, type } = event.detail
    this.showNotification(message, type || 'success')
  }

  // Muestra una notificación temporal
  showNotification(message, type = 'success') {
    // Definir colores según el tipo
    const colors = {
      success: 'bg-green-500',
      error: 'bg-red-500', 
      warning: 'bg-yellow-500',
      info: 'bg-blue-500'
    }

    // Crear elemento de notificación
    const notification = document.createElement('div')
    notification.classList.add(
      'fixed', 'top-4', 'right-4', 'px-4', 'py-2', 
      colors[type] || colors.success, 'text-white', 'rounded-md', 'shadow-lg',
      'transition-opacity', 'duration-300', 'z-50', 'max-w-sm'
    )
    notification.textContent = message
    
    // Agregar al DOM
    document.body.appendChild(notification)
    
    // Eliminar después del tiempo especificado
    setTimeout(() => {
      notification.classList.add('opacity-0')
      setTimeout(() => {
        if (notification.parentNode) {
          document.body.removeChild(notification)
        }
      }, 300)
    }, this.durationValue)
  }

  // Método estático para mostrar notificaciones desde cualquier lugar
  static show(message, type = 'success', duration = 3000) {
    const colors = {
      success: 'bg-green-500',
      error: 'bg-red-500', 
      warning: 'bg-yellow-500',
      info: 'bg-blue-500'
    }

    const notification = document.createElement('div')
    notification.classList.add(
      'fixed', 'top-4', 'right-4', 'px-4', 'py-2', 
      colors[type] || colors.success, 'text-white', 'rounded-md', 'shadow-lg',
      'transition-opacity', 'duration-300', 'z-50', 'max-w-sm'
    )
    notification.textContent = message
    
    document.body.appendChild(notification)
    
    setTimeout(() => {
      notification.classList.add('opacity-0')
      setTimeout(() => {
        if (notification.parentNode) {
          document.body.removeChild(notification)
        }
      }, 300)
    }, duration)
  }
}
