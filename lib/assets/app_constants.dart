class AppConstants {
  //Firebase Collections
  final String usersCollection = 'users';
  final String reviewsCollection = 'reviews';
  final String businessCollection = 'businesses';
  final String advertisementCollection = 'advertisements';

  //Texts for UI
  final authTexts = {
    'welcomeView': {
      'welcome': '¡Bienvenido, Héroe!',
      'login': 'Iniciar sesión',
      'register': 'Registrarse',
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
