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
    // Verificar si ya existe una alerta
    let alertModal = document.querySelector('#customAlert')

    if (!alertModal) {
      // Crear la alerta personalizada
      alertModal = document.createElement('div')
      alertModal.id = 'customAlert'
      alertModal.className = 'fixed inset-0 overflow-y-auto h-full w-full z-50'
      alertModal.style.backgroundColor = 'rgba(75, 85, 99, 0.5)' // Equivalente a bg-gray-600 con 50% opacity
      alertModal.innerHTML = `
        <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
          <div class="mt-3 text-center">
            <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-blue-100">
              <i class="nf nf-fa-question h-6 w-6 text-blue-600"></i>
            </div>
            <h3 class="text-lg leading-6 font-medium text-gray-900 mt-4">¿Quién eres en el grupo?</h3>
            <div class="mt-2 px-7 py-3">
              <p class="text-sm text-gray-500">
                No has indicado quién eres en el grupo. Aunque no es obligatorio, 
                se recomienda seleccionar tu nombre haciendo clic en el ícono de usuario. ¿Deseas continuar sin seleccionar o volver 
                para elegir tu participante?
              </p>
            </div>
            <div class="flex justify-center space-x-4 mt-4">
              <button id="alertCancel" class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-opacity-50">
                Volver
              </button>
              <button id="alertContinue" class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50">
                Continuar
              </button>
            </div>
          </div>
        </div>
      `
      document.body.appendChild(alertModal)
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
      console.log('Continuar clicked, modalTarget:', modalTarget)
      alertModal.classList.add('hidden')

      // Usar un pequeño delay para asegurar que el modal anterior se cierre completamente
      setTimeout(() => {
        // Continuar con la apertura del modal original usando el target guardado
        const modal = document.querySelector(modalTarget)
        console.log('Buscando modal:', modalTarget, 'Encontrado:', modal)
        if (modal) {
          console.log('Abriendo modal...')
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
