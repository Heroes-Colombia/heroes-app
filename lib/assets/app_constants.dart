class AppConstants {
  //Firebase Collections
  final String usersCollection = 'users';
  final String reviewsCollection = 'reviews';
  final String businessCollection = 'businesses';
  final String advertisementCollection = 'advertisements';

  //Firebase Storage
  final String userIdentifications = "identifications";

  //Texts for UI
  final entryPointTexts = {
    "unverifiedUserView": {
      "title": "Usuario no verificado",
      "content":
          'Lo sentimos pero tu usuario aún no ha sido verificado. Cuando tu perfil haya sido corroborado tendrás acceso a al aplicación.'
    },
  };
  final authTexts = {
    'welcomeView': {
      'welcome': '¡Bienvenido, Héroe!',
      'login': 'Iniciar sesión',
      'register': 'Registrarse',
      'registerComercio': 'Registrarse como comerciante',
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
      'username-label': 'Username',
      'username-hint': 'Ingresa tu username',
      'identification-card-label': 'Número de cédula de ciudadanía',
      'identification-card-hint': 'Ingresa tu número de cédula de ciudadanía',
      'identification-card-img-label': 'Foto de la cédula de ciudadanía',
      'identification-card-img-hint': 'Tomar foto a cédula de ciudadanía',
      'identification-card-img-filled': 'Tomar otra foto',
      'firstname-label': 'Nombre',
      'firstname-hint': 'Ingresa tu nombre',
      'secondname-label': 'Segundo nombre',
      'secondname-hint': 'Ingresa tu segundo nombre',
      'lastname-label': 'Apellido',
      'lastname-hint': 'Ingresa tu apellido',
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
      'username-label': 'Username',
      'username-hint': 'Ingresa tu username',
      'identification-card-label': 'Número de cédula de ciudadanía',
      'identification-card-hint': 'Ingresa tu número de cédula de ciudadanía',
      'identification-card-img-label': 'Foto de la cédula de ciudadanía',
      'identification-card-img-hint': 'Tomar foto a cédula de ciudadanía',
      'identification-card-img-filled': 'Tomar otra foto',
      'email-label': 'Correo electrónico',
      'email-hint': 'Ingresa tu correo electrónico',
      'email-validator': 'Por favor ingresa un correo electrónico válido',
      'address-label': 'Dirección',
      'address-hint': 'Ingresa la dirección del comercio',
      'identification-label': 'Identificación',
      'identification-hint': 'Ingresa la identificación del comercio',
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
      'lastname-label': 'Apellido',
      'lastname-hint': 'Ingresa tu apellido',
      'rank-label': 'Rango',
      'rank-hint': 'Ingresa tu rango',
      'password-label': 'Contraseña',
      'password-hint': 'Ingresa tu contraseña',
      'password-validator': 'Por favor ingresa tu contraseña',
      'signupButton': 'Registrarse',
      'signupErrorTitle': 'Error al registrarse',
      "registerComercio": "¿Registrar un nuevo comercio?",
      "personalInfo": "Información del dueño",
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
      'username-label': 'Username',
      'username-hint': 'Ingresa tu username',
      'firstname-label': 'Nombre',
      'firstname-hint': 'Ingresa tu nombre',
      'secondname-label': 'Segundo nombre',
      'secondname-hint': 'Ingresa tu segundo nombre',
      'lastname-label': 'Apellido',
      'lastname-hint': 'Ingresa tu apellido',
      'rank-label': 'Rango',
      'rank-hint': 'Ingresa tu rango',
      'savechanges-button': 'Guardar cambios',
      'error-content': 'Hubo un error al guardar los cambios',
      'success-content': 'Información actualizada',
      'empty-string': 'Este campo no puede estar vacío',
    }
  };
}
