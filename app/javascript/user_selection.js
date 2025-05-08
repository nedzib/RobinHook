// Funcionalidad para manejar la selección de usuario actual
document.addEventListener('DOMContentLoaded', function() {
  // Inicializar los iconos de usuario y cargar el usuario actual
  initializeUserIcons();
  loadCurrentUser();
  
  // Actualizar los campos ocultos con el usuario actual
  updateHiddenFields();
});

// Constantes
const CURRENT_USER_KEY = 'currentParticipantName';
const ICON_COLOR_ACTIVE = '#3b82f6'; // Azul
const ICON_COLOR_INACTIVE = '#9ca3af'; // Gris

// Inicializa los iconos de usuario junto a cada nombre de participante
function initializeUserIcons() {
  // Buscar todos los nombres de participantes en la lista principal y en subgrupos
  const participantNamesInTable = document.querySelectorAll('table tbody tr td:nth-child(2)');
  const participantNamesInSubgroups = document.querySelectorAll('li .text-gray-900');
  
  // Agregar iconos a los participantes en la lista principal
  participantNamesInTable.forEach(nameElement => {
    addUserIconToElement(nameElement);
  });
  
  // Agregar iconos a los participantes en subgrupos
  participantNamesInSubgroups.forEach(nameElement => {
    addUserIconToElement(nameElement);
  });
}

// Agrega el icono de usuario a un elemento dado
function addUserIconToElement(element) {
  if (!element) return;
  
  const participantName = element.textContent.trim();
  
  // Crear el icono de usuario
  const userIcon = document.createElement('span');
  userIcon.classList.add('user-icon', 'cursor-pointer', 'mr-1', 'inline-flex', 'items-center', 'justify-center');
  userIcon.dataset.participantName = participantName;
  
  // Agregar el SVG del icono de usuario (gris por defecto)
  userIcon.innerHTML = `
    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="${ICON_COLOR_INACTIVE}">
      <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd" />
    </svg>
  `;
  
  // Agregar evento de clic
  userIcon.addEventListener('click', function() {
    setCurrentUser(participantName);
  });
  
  // Insertar el icono antes del nombre
  element.insertBefore(userIcon, element.firstChild);
}

// Establece al participante actual y actualiza la UI
function setCurrentUser(participantName) {
  // Guardar en localStorage
  localStorage.setItem(CURRENT_USER_KEY, participantName);
  
  // Actualizar todos los iconos
  updateAllUserIcons(participantName);
  
  // Actualizar campos ocultos en formularios
  updateHiddenFields();
  
  // Mostrar mensaje de confirmación
  showNotification(`${participantName} ha sido establecido como usuario actual`);
}

// Carga el usuario actual desde localStorage
function loadCurrentUser() {
  const currentUser = localStorage.getItem(CURRENT_USER_KEY);
  if (currentUser) {
    updateAllUserIcons(currentUser);
  }
}

// Actualiza todos los iconos de usuario
function updateAllUserIcons(currentUserName) {
  const allUserIcons = document.querySelectorAll('.user-icon');
  
  allUserIcons.forEach(icon => {
    const svgElement = icon.querySelector('svg');
    const iconName = icon.dataset.participantName;
    
    if (iconName === currentUserName) {
      // Activar este icono
      svgElement.setAttribute('fill', ICON_COLOR_ACTIVE);
    } else {
      // Desactivar este icono
      svgElement.setAttribute('fill', ICON_COLOR_INACTIVE);
    }
  });
}

// Función para actualizar los campos ocultos en los formularios de muestreo
function updateHiddenFields() {
  const currentUser = localStorage.getItem(CURRENT_USER_KEY);
  if (!currentUser) return;
  
  // Actualizar todos los campos ocultos de usuario actual
  document.querySelectorAll('[id^="current_user_name_"]').forEach(field => {
    field.value = currentUser;
  });
}

// Función para mostrar una notificación temporal
function showNotification(message) {
  // Crear elemento de notificación
  const notification = document.createElement('div');
  notification.classList.add(
    'fixed', 'top-4', 'right-4', 'px-4', 'py-2', 
    'bg-blue-500', 'text-white', 'rounded-md', 'shadow-lg',
    'transition-opacity', 'duration-300', 'z-50'
  );
  notification.textContent = message;
  
  // Agregar al DOM
  document.body.appendChild(notification);
  
  // Eliminar después de 3 segundos
  setTimeout(() => {
    notification.classList.add('opacity-0');
    setTimeout(() => {
      document.body.removeChild(notification);
    }, 300);
  }, 3000);
}

// Función para verificar si el participante seleccionado es el usuario actual
function isCurrentUser(participantName) {
  const currentUser = localStorage.getItem(CURRENT_USER_KEY);
  return currentUser === participantName;
}

// Exportar funciones para uso global
window.getCurrentUser = function() {
  return localStorage.getItem(CURRENT_USER_KEY);
};

window.clearCurrentUser = function() {
  localStorage.removeItem(CURRENT_USER_KEY);
  updateAllUserIcons(null);
  updateHiddenFields();
  showNotification('Usuario actual eliminado');
};