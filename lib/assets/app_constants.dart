class AppConstants {
  //Firebase Collections
  final String usersCollection = 'users';
  final String reviewsCollection = 'reviews';
  final String businessCollection = 'businesses';
  final String advertisementCollection = 'advertisements';

  //Firebase Storage
  final String userIdentifications = "identifications";

  //User Ranks
  Map<String, Map<String, List<String>>> ranks = {
    "POLICIA NACIONAL": {
      "NIVEL EJECUTIVO": [
        "Patrullero",
        "Subintendente",
        "Intendente",
        "Intendente jefe",
        "Subcomisario",
        "Comisario",
        "En uso de buen retiro",
      ],
      "SUBOFICIALES": [
        "cabo segundo",
        "cabo primero",
        "sargento segundo",
        "sargento viceprimero",
        "sargento primero",
        "sargento mayor",
        "en uso de buen retiro",
      ],
      "OFICIALES": [
        "subteniente",
        "teniente",
        "capitán",
        "mayor",
        "teniente coronel",
        "coronel",
        "brigadier general",
        "mayor general",
        "teniente general",
        "general",
        "en uso de buen retiro",
      ],
      "GRADOS EN LAS ESCUELAS DE FORMACIÓN": [
        "Estudiante",
        "Cadete",
        "Alférez",
      ],
      "OTROS GRADOS": [
        "Personal no uniformado",
        "Auxiliar de policía",
        "Beneficiario (padres, hijos, esposa)",
      ],
    },
    "EJÉRCITO NACIONAL": {
      "SUBOFICIALES": [
        "Cabo tercero",
        "Cabo segundo",
        "Cabo primero",
        "Sargento segundo",
        "Sargento viceprimero",
        "Sargento primero",
        "Sargento mayor",
        "Sargento mayor de comando",
        "Sargento mayor de comando conjunto",
        "En uso de buen retiro",
      ],
      "OFICIALES": [
        "Subteniente",
        "Teniente",
        "Capitán",
        "Mayor",
        "Teniente coronel",
        "Coronel",
        "Brigadier general",
        "Mayor general",
        "General",
        "En uso de buen retiro",
        "Soldado profesional",
        "En uso de buen retiro",
      ],
      "GRADOS EN LAS ESCUELAS DE FORMACIÓN": [
        "Estudiante",
        "Cadete",
        "Alférez",
      ],
      "OTROS GRADOS": [
        "Personal civil",
        "Servicio militar",
        "Beneficiarios",
      ],
    },
    "ARMADA NACIONAL": {
      "SUBOFICIALES": [
        "Marinero segundo",
        "Marinero primero",
        "Suboficial tercero",
        "Suboficial segundo",
        "Suboficial primero",
        "Suboficial jefe",
        "Suboficial jefe técnico",
        "Suboficial jefe técnico de comando",
        "Suboficial jefe técnico de comando conjunto",
        "En uso de buen retiro",
      ],
      "OFICIALES": [
        "Teniente de corbeta",
        "Teniente de fragata",
        "Teniente de navío",
        "Capitán de corbeta",
        "Capitán de fragata",
        "Capitán de navío",
        "Contraalmirante",
        "Vicealmirante",
        "Almirante",
        "En uso de buen retiro",
      ],
      "OTROS GRADOS": [
        "Infante de marina",
        "Alumno de infantería",
        "Cadete de marina",
        "Personal civil",
        "Beneficiarios",
      ],
    },
    "FUERZA AEROESPACIAL": {
      "SUBOFICIALES": [
        "Aerotécnico",
        "Técnico cuarto",
        "Técnico tercero",
        "Técnico segundo",
        "Técnico primero",
        "Técnico subjefe",
        "Técnico jefe",
        "Técnico jefe de comando",
        "En uso de buen retiro",
      ],
      "OFICIALES": [
        "Subteniente",
        "Teniente",
        "Capitán",
        "Mayor",
        "Teniente coronel",
        "Coronel",
        "Brigadier general",
        "Mayor general",
        "General",
        "En uso de buen retiro",
      ],
      "OTROS GRADOS": [
        "Estudiante",
        "Personal civil",
        "Soldado (servicio militar)",
      ],
    },
    /*
    // Please especify if the Opcionales are needed to be shown
    "OPCIONALES": {
      "BOMBEROS": [
        // Please especify the options for Bomberos
      ],
      "DEFENSA CIVIL": [
        // Please especify the options for Defensa Civil
      ],
      "FISCALIA GENERAL DE LA NACION": [
        // Please especify the options for Fiscalia General de la Nacion
      ],
      "MINISTERIO DE DEFENSA": [
        // Please especify the options for Ministerio de Defensa
      ],
    },
    */
  };

  //Texts for UI
  final entryPointTexts = {
    "unverifiedUserView": {
      "title": "Usuario no verificado",
      "content":
          'Lo sentimos pero tu usuario aún no ha sido verificado. Cuando tu perfil haya sido corroborado tendrás acceso a la aplicación.'
    },
  };
  final authTexts = {
    'welcomeView': {
      'welcome': '¡Bienvenido, Héroe!',
      'login': 'Iniciar sesión',
      'register': 'Registrarse',
      'registerAsBusiness': 'Registrarse como comerciante',
    },
    'loginView': {
      'title': 'Iniciar sesión',
      'forgotPassword': 'Olvidé mi contraseña',
      'email-label': 'Correo electrónico',
      'email-hint': 'Ingresa tu correo electrónico',
      'email-validator': 'Por favor ingresa un correo electrónico válido',
      'password-label': 'Contraseña',
      'password-hint': 'Ingresa tu contraseña',
      'password-validator': 'Por favor ingresa tu contraseña',
      'password-length-validator':
          'La contraseña debe tener al menos 6 caracteres',
      'loginButton': 'Iniciar sesión',
      'loginErrorTitle': 'Error',
      'loginErrorContent': 'Las credenciales no son válidas',
      'loginErrorButton': 'Aceptar',
    },
    'signupView': {
      'title': 'Registrarse',
      'email-label': 'Correo electrónico',
      'email-hint': 'Ingresa tu correo electrónico',
      'email-validator': 'Por favor ingresa un correo electrónico válido',
      'license-label': 'Carnet',
      'license-hint': 'Ingresa tu carnet',
      'identification-card-label': 'Número de cédula de ciudadanía',
      'identification-card-hint': 'Ingresa tu número de cédula de ciudadanía',
      'identification-card-img-label': 'Foto del carnet',
      'identification-card-img-hint': 'Tomar foto a carnet',
      'identification-card-img-filled': 'Tomar otra foto',
      'firstname-label': 'Nombre',
      'firstname-hint': 'Ingresa tu nombre',
      'secondname-label': 'Segundo nombre',
      'secondname-hint': 'Ingresa tu segundo nombre',
      'first-lastname-label': 'Primer apellido',
      'first-lastname-hint': 'Ingresa tu primer apellido',
      'second-lastname-label': 'Segundo apellido',
      'second-lastname-hint': 'Ingresa tu segundo apellido',
      'rank-label': 'Rango',
      'rank-hint': 'Ingresa tu rango',
      'password-label': 'Contraseña',
      'password-hint': 'Ingresa tu contraseña',
      'password-validator': 'Por favor ingresa tu contraseña',
      'signupButton': 'Registrarse',
      'signupErrorTitle': 'Error al registrarse',
      "genericValidator": "Este campo no puede estar vacío",
      "registerSuccess-title": "¡Registro exitoso!",
      "registerSuccess-body":
          "Tu cuenta ha sido creada exitosamente. Por favor espera a que tu cuenta sea verificada para poder ingresar a la aplicación.",
      "registerSuccess-button": "Aceptar",
    },
    'signupBusinessView': {
      'title': 'Registrar comerciante',
      'identification-card-label': 'Número de cédula de ciudadanía',
      'identification-card-hint': 'Ingresa tu número de cédula de ciudadanía',
      'identification-card-img-label': 'Foto del RUT del comercio',
      'identification-card-img-hint': 'Tomar foto al RUT del comercio',
      'identification-card-img-filled': 'Tomar otra foto',
      'email-label': 'Correo electrónico',
      'email-hint': 'Ingresa tu correo electrónico',
      'email-validator': 'Por favor ingresa un correo electrónico válido',
      'address-label': 'Dirección',
      'address-hint': 'Ingresa la dirección del comercio',
      'identification-label': 'NIT',
      'identification-hint': 'Ingresa el NIT del comercio',
      'name-label': 'Nombre del comercio',
      'name-hint': 'Ingresa el nombre del comercio',
      'ownername-label': 'Nombre del dueño',
      'ownername-hint': 'Ingresa el nombre del dueño del comercio',
      'phone-label': 'Teléfono',
      'phone-hint': 'Ingresa el teléfono del comercio',
      'firstname-label': 'Nombre',
      'firstname-hint': 'Ingresa tu nombre',
      'secondname-label': 'Segundo nombre',
      'secondname-hint': 'Ingresa tu segundo nombre',
      'first-lastname-label': 'Primer apellido',
      'first-lastname-hint': 'Ingresa tu primer apellido',
      'second-lastname-label': 'Segundo apellido',
      'second-lastname-hint': 'Ingresa tu segundo apellido',
      'rank-label': 'Cargo o posición',
      'rank-hint': 'Ingresa tu cargo o posición',
      'password-label': 'Contraseña',
      'password-hint': 'Ingresa tu contraseña',
      'password-validator': 'Por favor ingresa tu contraseña',
      'signupButton': 'Registrarse',
      'signupErrorTitle': 'Error al registrarse',
      "registerAsBusiness": "¿Registrar un nuevo comercio?",
      "personalInfo": "Información del manager o responsable",
      "genericValidator": "Este campo no puede estar vacío",
      "registerSuccess-title": "¡Registro exitoso!",
      "registerSuccess-body":
          "Tu cuenta ha sido creada exitosamente. Por favor espera a que tu cuenta sea verificada para poder ingresar a la aplicación.",
      "registerSuccess-button": "Aceptar",
    },
    'restorePasswordView': {
      'title': '¿Olvidaste tu contraseña?',
      'email-label': 'Correo electrónico',
      'email-hint': 'Ingresa tu correo electrónico',
      'email-validator': 'Por favor ingresa un correo electrónico válido',
      'restoreButton': 'Recuperar',
      'email-sent': 'Revisa tu correo electrónico para recuperar tu contraseña',
      'email-not-found': 'Correo electrónico no encontrado',
      'try-again': 'Intentar de nuevo',
    },
  };
  final dashBoardTexts = {
    'profileView': {
      'title': 'Ajustes',
      'account': 'Cuenta',
      'edit-profile': 'Editar perfil',
      'logout': 'Cerrar sesión',
      'settings': 'Ajustes',
      'dark-mode': 'Tema oscuro',
      'light-mode': 'Tema claro',
      'system-mode': 'Tema del sistema',
      'logout-error-message': 'Ocurrió un error al cerrar sesión',
    },
    'editprofileView': {
      'title': 'Editar perfil',
      'error-title': 'Error',
      'email-label': 'Correo electrónico',
      'email-hint': 'Ingresa tu correo electrónico',
      'email-validator': 'Por favor ingresa un correo electrónico válido',
      'firstname-label': 'Nombre',
      'firstname-hint': 'Ingresa tu nombre',
      'secondname-label': 'Segundo nombre',
      'secondname-hint': 'Ingresa tu segundo nombre',
      'first-lastname-label': 'Primer apellido',
      'first-lastname-hint': 'Ingresa tu primer apellido',
      'second-lastname-label': 'Segundo apellido',
      'second-lastname-hint': 'Ingresa tu segundo apellido',
      'rank-label': 'Rango',
      'rank-hint': 'Ingresa tu rango',
      'savechanges-button': 'Guardar cambios',
      'error-content': 'Hubo un error al guardar los cambios',
      'success-content': 'Información actualizada',
      'empty-string': 'Este campo no puede estar vacío',
    }
  };
}
