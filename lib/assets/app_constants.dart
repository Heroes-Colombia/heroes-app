class AppConstants {
  //Firebase Collections
  final String usersCollection = 'users';
  final String reviewsCollection = 'reviews';
  final String businessCollection = 'businesses';
  final String advertisementCollection = 'advertisements';

  //Firebase Storage
  final String userIdentifications = "identifications";
  final String businessesImages = "businessesImages";
  final String promotionImages = "promotionsImages";
  final String featureImage = "featureImage";

  //Map themes
  final String lightMapTheme = "7f1b54e9ff3283c0";
  final String darkMapTheme = "b3f5bac810144125";

  //Firebase Cloud Messaging topics

  //Types of users in the app (used to filter the users in the admin panel)
  final String businessUserTopic = "business";
  final String normalUserTopic = "user";

  //Used to send notifications to users with the business in their favourites
  final String favoriteTopic = "favoriteBusinessPromotion";

  //Used to send notifications to users of a nearby business
  final String discoverTopic = "discoverNearbyBusiness";

  //Google maps static api
  final String googleMapsStaticApi =
      "https://maps.googleapis.com/maps/api/staticmap";

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
      "personalInfo": "Información del administrador o responsable",
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
    "searchView": {
      "title": "Comercios aliados",
      "search-title": "¿Qué comercio buscas?",
      "nearPromotions": "Comercios cercanos",
      "featuredBusiness": "Comercios destacados",
      "business": "Comercios",
      "seeAll": "Ver todos",
      "search-business": "Buscar comercio",
      "no-results": "No se encontraron resultados",
    },
    "allBusinessView": {
      "title": "Comercios",
      "loading-title": "Cargando",
      "error-title": "Error",
      "error-content": "Ocurrió un error al cargar los comercios",
      "error-button": "Reintentar"
    },
    "favouriteView": {
      "title": "Favoritos",
      "loading-title": "Cargando",
      "error-title": "Error",
      "error-content": "Ocurrió un error al cargar los comercios favoritos",
      "error-button": "Reintentar",
      "empty-content": "No tienes comercios favoritos",
    },
    "businessDetailsView": {
      "loading-title": "Cargando",
      "loading-content": "Cargando información del comercio",
      "promotions-title": "Promociones",
      "comments-title": "Comentarios",
      "comments-button": "Ver todos",
      "add-comment-title":
          "Te gustaría compartir tu experiencia con este negocio?",
      "add-comment-button": "Agregar review",
      "empty-comment-title":
          "Este comercio aún no cuenta con comentarios activas, ¿Has visitado este comercio, te gustaría compartir tu experiencia con este negocio?",
      "navigation-title": "Navegar al comercio",
      "error-title": "Error",
      "error-content": "Ocurrió un error al cargar la información del comercio",
      "error-button": "Reintentar",
      "empty-promotions-title": "¡Lo sentimos!",
      "empty-promotions": "Este comercio no tiene promociones activas",
      "raiting": "Calificación",
      "comment": "Comentario",
      "add-review": "Crear una reseña",
      "create-review": "Agregar reseña",
      "comment-hint": "Ingresa tu comentario",
      "comment-validator": "Por favor ingresa tu comentario",
      "review-success-title":
          "¡Reseña creada! Espera a que sea aprobada para que sea visible",
    },
    "promotionDetailsView": {
      "description-title": "Descripción",
      "instructions-title": "Instrucciones",
      "expiration-title": "Fecha de expiración",
    },
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
    },
    'mapView': {
      'title': 'Mapa',
      'search': 'Buscar',
      'search-hint': 'Buscar comercio',
      'search-error': 'No se encontraron resultados',
      'search-error-button': 'Reintentar',
      'search-error-title': 'Error',
      'search-error-content': 'Ocurrió un error al buscar',
      "search-suggestions": "Sugerencias",
      "search-results": "Resultados",
    }
  };
  final businessDashboardTexts = {
    "ownedBusinessesView": {
      "title": "Mis comercios",
      "loading-title": "Cargando",
      "error-title": "Error",
      "error-content": "Ocurrió un error al cargar los comercios",
      "error-button": "Reintentar",
      "empty-content": "No tienes comercios asignados",
    },
    "ownedBusinessDetailsView": {
      "loading-title": "Cargando",
      "loading-content": "Cargando información del comercio",
      "promotions-title": "Promociones",
      "add-promotion-title": "Agregar promoción",
      "error-title": "Error",
      "error-content": "Ocurrió un error al cargar la información del comercio",
      "error-button": "Reintentar",
      "empty-promotions-title": "¡Lo sentimos!",
      "empty-promotions": "Este comercio no tiene promociones activas",
      "review-success-title":
          "¡Reseña creada! Espera a que sea aprobada para que sea visible",
      "empty-value": "Por favor ingresa un valor",
      "featured-img-filled": "Seleccionar otra foto",
      "featured-img-hint": "Foto de la promoción",
      "cancel-button": "Cancelar",
      "title-label": "Título",
      "title-hint": "Ingresa el título de la promoción",
      "status-label": "Estado",
      "status-hint": "Selecciona el estado de la promoción",
      "active": "Activa",
      "pending": "Pendiente",
      "inactive": "Inactiva",
      "description-label": "Descripción",
      "description-hint": "Ingresa la descripción de la promoción",
      "instructions-label": "Instrucciones",
      "instructions-hint": "Ingresa las instrucciones de la promoción",
      "percentage-label": "Porcentaje",
      "percentage-hint": "Ingresa el porcentaje de la promoción",
      "expiration-date-label": "Fecha de expiración",
      "expiration-date-hint": "Ingresa la fecha de expiración de la promoción",
      "promotion-created": "Promoción creada",
      "promotion-edited": "Promoción editada",
      "promotion-error": "Ocurrió un error al crear la promoción",
      "promotion-delete-error": "Ocurrió un error al eliminar la promoción",
      "promotion-deleted": "Promoción eliminada",
      "create-button": "Crear",
      "edit-button": "Editar",
      "delete-button": "Eliminar",
      "add-manager-button": "Agregar administrador",
      "remove-manager-button": "Eliminar",
      "slide-to-remove": "Desliza para eliminar administrador",
      "manager-deleted": "Administrador eliminado exitosamente",
      "manager-delete-error": "Ocurrió un error al eliminar el administrador",
      "email-error": "Por favor ingresa un correo electrónico válido",
      "manager-added": "Administrador agregado exitosamente",
      "email-label": "Correo electrónico",
      "email-hint": "Ingresa el correo electrónico del administrador",
      "add-button": "Agregar",
      "address-label": "Ubicación",
      "address-hint": "Ingresa la ubicación del comercio",
      "address-edited": "Ubicación editada exitosamente",
      "address-error": "Por favor ingresa una ubicación válida",
    },
  };
}
