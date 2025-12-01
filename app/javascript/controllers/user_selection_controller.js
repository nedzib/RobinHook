import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon", "hiddenField"]
  static values = { 
    participantName: String,
    storageKey: { type: String, default: "currentParticipantName" },
    activeColor: { type: String, default: "#3b82f6" },
    inactiveColor: { type: String, default: "#9ca3af" }
  }

  connect() {
    this.loadCurrentUser()
    this.updateHiddenFields()
  }

  // Establece este participante como usuario actual o lo deselecciona si ya está seleccionado
  selectUser(event) {
    event.preventDefault()
    
    const currentUser = localStorage.getItem(this.storageKeyValue)
    
    // Si el usuario ya está seleccionado, deseleccionarlo
    if (currentUser === this.participantNameValue) {
      this.clearCurrentUser()
      this.showNotification(`${this.participantNameValue} ha sido deseleccionado`)
    } else {
      // Guardar en localStorage
      localStorage.setItem(this.storageKeyValue, this.participantNameValue)
      
      // Actualizar todos los iconos
      this.updateAllUserIcons(this.participantNameValue)
      
      // Actualizar campos ocultos
      this.updateHiddenFields()
      
      // Mostrar notificación
      this.showNotification(`${this.participantNameValue} ha sido establecido como usuario actual`)
    }
  }

  // Limpia la selección del usuario actual
  clearCurrentUser() {
    localStorage.removeItem(this.storageKeyValue)
    
    // Actualizar todos los iconos al estado inactivo
    this.updateAllUserIcons(null)
    
    // Limpiar campos ocultos
    this.clearHiddenFields()
    
    // Disparar evento personalizado para notificar a otros controladores
    document.dispatchEvent(new CustomEvent('user-selection:cleared'))
  }

  // Limpia todos los campos ocultos
  clearHiddenFields() {
    // Limpiar campos ocultos en esta instancia del controlador
    this.hiddenFieldTargets.forEach(field => {
      field.value = ""
    })
    
    // Limpiar todos los campos ocultos globales
    document.querySelectorAll('[id^="current_user_name_"]').forEach(field => {
      field.value = ""
    })
  }

  // Carga el usuario actual desde localStorage
  loadCurrentUser() {
    const currentUser = localStorage.getItem(this.storageKeyValue)
    if (currentUser) {
      this.updateAllUserIcons(currentUser)
    }
  }

  // Actualiza todos los iconos de usuario en la página
  updateAllUserIcons(currentUserName) {
    // Buscar todos los controladores de selección de usuario
    const allControllers = this.application.getControllerForElementAndIdentifier(
      document.documentElement, 
      "user-selection"
    )
    
    // Método alternativo: buscar por clase CSS y aplicar halo al contenedor
    document.querySelectorAll('[data-controller*="user-selection"]').forEach(element => {
      const controller = this.application.getControllerForElementAndIdentifier(element, "user-selection")
      if (!controller) return

      const iconName = controller.participantNameValue

      // Preferir target de icono si existe
      let targetEl = null
      if (controller.hasIconTarget) {
        targetEl = controller.iconTarget
      } else {
        targetEl = controller.element
      }

      // Si dentro del target hay un <i> (nerd-fonts icon), colorearlo; si no, aplicar/unapply halo en el contenedor
      const innerIcon = targetEl.querySelector && targetEl.querySelector('i')

      const checkEl = targetEl.querySelector && targetEl.querySelector('.selected-check')

      if (currentUserName && iconName === currentUserName) {
        if (innerIcon) {
          innerIcon.style.color = this.activeColorValue
        } else {
          // añadir clase dedicada para halo
          targetEl.classList.add('selected-user-ring')
        }
        if (checkEl) checkEl.classList.remove('hidden')
      } else {
        if (innerIcon) {
          innerIcon.style.color = this.inactiveColorValue
        } else {
          targetEl.classList.remove('selected-user-ring')
        }
        if (checkEl) checkEl.classList.add('hidden')
      }
    })
  }

  // Actualiza todos los campos ocultos con el usuario actual
  updateHiddenFields() {
    const currentUser = localStorage.getItem(this.storageKeyValue)
    if (!currentUser) return
    
    // Actualizar campos ocultos en esta instancia del controlador
    this.hiddenFieldTargets.forEach(field => {
      field.value = currentUser
    })
    
    // Actualizar todos los campos ocultos globales
    document.querySelectorAll('[id^="current_user_name_"]').forEach(field => {
      field.value = currentUser
    })
  }

  // Función para mostrar una notificación temporal
  showNotification(message) {
    // Crear elemento de notificación
    const notification = document.createElement('div')
    notification.classList.add(
      'fixed', 'top-4', 'right-4', 'px-4', 'py-2', 
      'bg-blue-500', 'text-white', 'rounded-md', 'shadow-lg',
      'transition-opacity', 'duration-300', 'z-50'
    )
    notification.textContent = message
    
    // Agregar al DOM
    document.body.appendChild(notification)
    
    // Eliminar después de 3 segundos
    setTimeout(() => {
      notification.classList.add('opacity-0')
      setTimeout(() => {
        if (notification.parentNode) {
          document.body.removeChild(notification)
        }
      }, 300)
    }, 3000)
  }

  // Función utilitaria para obtener el usuario actual
  static getCurrentUser() {
    return localStorage.getItem("currentParticipantName")
  }

  // Función utilitaria para limpiar el usuario actual
  static clearCurrentUser() {
    localStorage.removeItem("currentParticipantName")
    // Disparar evento personalizado para notificar a otros controladores
    document.dispatchEvent(new CustomEvent('user-selection:cleared'))
  }
}
