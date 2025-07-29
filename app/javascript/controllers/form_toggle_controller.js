import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "button"]

  // Alterna la visibilidad del formulario
  toggle(event) {
    event?.preventDefault()
    
    if (this.formTarget.style.display === 'none' || !this.formTarget.style.display) {
      this.show()
    } else {
      this.hide()
    }
  }

  // Muestra el formulario y oculta el botón
  show() {
    this.formTarget.style.display = 'block'
    if (this.hasButtonTarget) {
      this.buttonTarget.style.display = 'none'
    }
    
    // Enfocar el primer input del formulario
    const firstInput = this.formTarget.querySelector('input[type="text"], input[type="email"], textarea')
    if (firstInput) {
      firstInput.focus()
    }
  }

  // Oculta el formulario y muestra el botón
  hide() {
    this.formTarget.style.display = 'none'
    if (this.hasButtonTarget) {
      this.buttonTarget.style.display = 'block'
    }
  }

  // Inicializa el estado del formulario al conectarse
  connect() {
    this.hide() // Asegurar que el formulario esté oculto al inicio
  }

  // Maneja el envío del formulario
  submit(event) {
    // Permitir que el formulario se envíe normalmente
    // Después del envío exitoso, el formulario se ocultará automáticamente
  }

  // Cancela y oculta el formulario
  cancel(event) {
    event?.preventDefault()
    
    // Limpiar el formulario
    const form = this.formTarget.querySelector('form')
    if (form) {
      form.reset()
    }
    
    this.hide()
  }
}
