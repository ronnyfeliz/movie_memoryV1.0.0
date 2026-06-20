// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MovieMemory';

  @override
  String get discover => 'Descubrir';

  @override
  String get search => 'Buscar';

  @override
  String get searchHint => 'Buscar películas, series...';

  @override
  String get library => 'Librería';

  @override
  String get profile => 'Perfil';

  @override
  String get myLibrary => 'Mi Librería';

  @override
  String get watchLater => 'Ver después';

  @override
  String get watched => 'Vistos';

  @override
  String get favorites => 'Favoritos';

  @override
  String get customLists => 'Mis Listas';

  @override
  String get listsNav => 'Listas';

  @override
  String get createList => 'Crear lista';

  @override
  String get createListTitle => 'Nueva lista';

  @override
  String get listName => 'Nombre de la lista';

  @override
  String get listDescription => 'Descripción (opcional)';

  @override
  String get cancel => 'Cancelar';

  @override
  String get create => 'Crear';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Cerrar';

  @override
  String get deleteListTitle => 'Eliminar lista';

  @override
  String deleteListMessage(Object name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get deleteItemTitle => 'Eliminar ficha';

  @override
  String deleteItemMessage(Object name) {
    return '¿Eliminar \"$name\" de esta lista?';
  }

  @override
  String get saveChangesTitle => 'Guardar cambios';

  @override
  String get saveChangesMessage => '¿Guardar los cambios realizados?';

  @override
  String get emptyList => 'Esta lista está vacía';

  @override
  String itemsCount(Object count) {
    return '$count items';
  }

  @override
  String get noResults => 'Sin resultados en esta categoría';

  @override
  String get nothingHere => 'Nada aquí todavía';

  @override
  String get tryOtherCategory => 'Prueba seleccionando otra categoría';

  @override
  String get searchAndAdd =>
      'Busca películas, series y otros contenidos, organiza tus listas y comparte tus descubrimientos con la comunidad.';

  @override
  String get createFirstList => 'Crea tu primera lista personalizada';

  @override
  String get all => 'Todos';

  @override
  String get movie => 'Película';

  @override
  String get series => 'Serie';

  @override
  String get anime => 'Anime';

  @override
  String get cartoon => 'Caricatura';

  @override
  String get documentary => 'Documental';

  @override
  String get concert => 'Concierto';

  @override
  String get other => 'Otro';

  @override
  String get noSynopsis => 'Sin sinopsis disponible';

  @override
  String get inYourLibrary => 'En tu librería';

  @override
  String get actions => 'Acciones';

  @override
  String get addToWatchLater => 'Ver después';

  @override
  String get markAsWatched => 'Ya visto';

  @override
  String get addToFavorites => 'Agregar a favoritos';

  @override
  String get removeFromFavorites => 'Quitar de favoritos';

  @override
  String get moveToWatchLater => 'Mover a Ver después';

  @override
  String get markAsWatchedAction => 'Marcar como visto';

  @override
  String get removeFromLibrary => 'Eliminar de la librería';

  @override
  String get addedToFavorites => 'Agregado a favoritos';

  @override
  String get addedToWatchLater => 'Agregado a Ver después';

  @override
  String get markedAsWatched => 'Marcado como visto';

  @override
  String get addedToLibrary => 'Agregado a la librería';

  @override
  String get removedFromLibrary => 'Eliminado de la librería';

  @override
  String get errorLoading => 'Error al cargar';

  @override
  String get error => 'Error';

  @override
  String get loggedInAs => 'Iniciaste sesión con Google';

  @override
  String get memberSince => 'Miembro desde';

  @override
  String get total => 'Total';

  @override
  String get viewed => 'Vistos';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutTitle => '¿Deseas cerrar sesión?';

  @override
  String get logoutMessage =>
      'Tendrás que volver a iniciar sesión para acceder a tu cuenta.';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get settings => 'Ajustes';

  @override
  String get firstName => 'Nombre';

  @override
  String get lastName => 'Apellidos';

  @override
  String get age => 'Edad';

  @override
  String get email => 'Correo electrónico';

  @override
  String get gender => 'Género';

  @override
  String get bio => 'Biografía';

  @override
  String get photoURL => 'URL de foto de perfil';

  @override
  String get male => 'Masculino';

  @override
  String get female => 'Femenino';

  @override
  String get nonBinary => 'No binario';

  @override
  String get preferNotToSay => 'Prefiero no decirlo';

  @override
  String get otherGender => 'Otro';

  @override
  String get profileUpdated => 'Perfil actualizado correctamente';

  @override
  String get profileUpdateError => 'Error al actualizar el perfil';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';

  @override
  String get portuguese => 'Portugués';

  @override
  String get italian => 'Italiano';

  @override
  String get french => 'Francés';

  @override
  String get russian => 'Ruso';

  @override
  String get korean => 'Coreano';

  @override
  String get japanese => 'Japonés';

  @override
  String get chinese => 'Chino';

  @override
  String get share => 'Compartir';

  @override
  String shareMovie(Object title, Object type) {
    return 'Mira esta $type: $title';
  }

  @override
  String shareMovieDescription(Object overview) {
    return '$overview';
  }

  @override
  String shareList(Object name) {
    return 'Lista: $name';
  }

  @override
  String shareListDescription(Object count, Object description) {
    return '$description\n$count items en MovieMemory';
  }

  @override
  String shareListItems(Object name) {
    return 'Contenido en $name:';
  }

  @override
  String get addToList => 'Agregar a lista';

  @override
  String get addToListTitle => 'Agregar a lista';

  @override
  String get selectList => 'Selecciona una lista';

  @override
  String get addedToList => 'Agregado a la lista';

  @override
  String get editList => 'Editar lista';

  @override
  String get editListTitle => 'Editar lista';

  @override
  String get newFieldRequired => 'Este campo es requerido';

  @override
  String get fieldRequired => 'Este campo es requerido';

  @override
  String get invalidEmail => 'Correo electrónico inválido';

  @override
  String get ageRange => 'Debe ser entre 0 y 150';

  @override
  String get saveConfirmation => '¿Guardar los cambios?';

  @override
  String get typeMovie => 'película';

  @override
  String get typeSeries => 'serie';

  @override
  String get markAsWatchedShort => 'Visto';

  @override
  String get favoriteShort => 'Favorito';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get loading => 'Cargando...';

  @override
  String get retry => 'Reintentar';

  @override
  String get noItemsInList => 'No hay items en esta lista';

  @override
  String get listInfo => 'Información de la lista';

  @override
  String get searchResults => 'Resultados de búsqueda';

  @override
  String get user => 'Usuario';

  @override
  String get trending => 'Tendencias hoy';

  @override
  String get nowPlaying => 'Ahora en cines';

  @override
  String get popularMovies => 'Películas populares';

  @override
  String get popularTv => 'Series populares';

  @override
  String get topRated => 'Mejor calificadas';

  @override
  String get loginSubtitle =>
      'Plataforma para descubrir, organizar y disfrutar contenido multimedia.';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get or => 'o';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get signIn => 'Ingresar';

  @override
  String get noAccount => '¿No tienes cuenta?';

  @override
  String get signUp => 'Regístrate';

  @override
  String get googleSignInError => 'Error al iniciar con Google';

  @override
  String get fillAllFields => 'Completa todos los campos';

  @override
  String get verifyEmailFirst =>
      'Debes verificar tu correo antes de iniciar sesión';

  @override
  String get wrongCredentials => 'Credenciales incorrectas';

  @override
  String get loginError => 'Error al iniciar sesión';

  @override
  String get enterEmailFirst => 'Escribe tu correo primero';

  @override
  String get recoveryEmailSent => 'Correo de recuperación enviado';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get registerSubtitle =>
      'Gestiona tu librería, crea listas personalizadas y comparte.';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get lastNameLabel => 'Apellido';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get logIn => 'Inicia sesión';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get registrationSuccess => 'Registro exitoso';

  @override
  String get confirmationSent =>
      'Enlace de confirmación enviado a su correo. Revise su bandeja de entrada o la carpeta de spam.';

  @override
  String get accept => 'ACEPTAR';

  @override
  String get completeAllFields => 'Completa todos los campos';

  @override
  String get mustBe18 => 'Debes tener al menos 18 años para registrarte';

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String minPasswordLength(Object length) {
    return 'La contraseña debe tener al menos $length caracteres';
  }

  @override
  String get emailAlreadyInUse => 'Correo ya en uso';

  @override
  String get checkYourEmail => '¡Revisa tu correo!';

  @override
  String get verificationSentTo => 'Enviamos un enlace de verificación a:';

  @override
  String get clickToActivate =>
      'Haz click en el enlace del correo para activar tu cuenta e iniciar sesión.';

  @override
  String get noEmailCheckSpam =>
      '¿No ves el correo? Revisa tu carpeta de spam o correo no deseado.';

  @override
  String get goToLogin => 'Ir al Login';

  @override
  String get yourPreferences => 'Tus gustos';

  @override
  String get selectFavoriteGenres =>
      'Selecciona tus géneros favoritos para recibir recomendaciones personalizadas';

  @override
  String get favoriteGenres => 'Géneros favoritos';

  @override
  String get contentTypes => 'Tipos de contenido';

  @override
  String get start => 'Comenzar';

  @override
  String get skip => 'Omitir';

  @override
  String get synopsis => 'Sinopsis';

  @override
  String get movedToWatchLater => 'Movido a Ver después';

  @override
  String get minutesLabel => 'min';

  @override
  String get searchHintEmpty => 'Escribe algo para buscar';

  @override
  String get noResultsSearch => 'Sin resultados';

  @override
  String get theme => 'Tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get systemTheme => 'Sistema';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get appDescription =>
      'MovieMemory es tu plataforma personal para descubrir, organizar y disfrutar contenido multimedia. Gestiona tu librería, crea listas personalizadas y comparte con la comunidad.';

  @override
  String get developer => 'Desarrollador';

  @override
  String get credits =>
      'Este producto usa la API de TMDB pero no está respaldado ni certificado por TMDB.';

  @override
  String get releaseDate => 'Fecha de lanzamiento';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get deleteAccountMessage =>
      '¿Estás seguro? Esta acción no se puede deshacer. Todos tus datos se eliminarán permanentemente.';

  @override
  String get deleteAccountConfirm =>
      'Esto eliminará permanentemente todos tus datos.';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationType => 'Tipo de notificación';

  @override
  String get normal => 'Normal';

  @override
  String get popup => 'Pop-up';

  @override
  String get both => 'Ambos';

  @override
  String get soundSettings => 'Configuración de sonido';

  @override
  String get openAppSound => 'Sonido de inicio';

  @override
  String get clickSound => 'Sonido de clic';

  @override
  String get addSound => 'Sonido de agregar';

  @override
  String get confirmSound => 'Sonido de confirmar';

  @override
  String get removeSound => 'Sonido de eliminar';

  @override
  String get errorSound => 'Sonido de error';

  @override
  String get freesoundCredit => 'Sonidos bajo licencia Free Commons';

  @override
  String get notificationSound => 'Sonido de notificación';

  @override
  String get supportEmail => 'Correo de soporte';

  @override
  String get silentMode => 'Modo silencioso';

  @override
  String get silentModeDesc => 'Desactiva todos los sonidos de la aplicación';

  @override
  String get playbackLanguage => 'Idioma de reproducción';

  @override
  String get defaultAudioLanguage => 'Idioma de audio por defecto';

  @override
  String get defaultSubtitleLanguage => 'Idioma de subtítulos por defecto';

  @override
  String get appLanguage => 'Idioma de la app';

  @override
  String get systemLanguage => 'Idioma del sistema';

  @override
  String get originalLanguage => 'Idioma original';

  @override
  String get subtitlesDisabled => 'Desactivados';

  @override
  String get exitPlayerTitle => '¿Deseas salir del reproductor?';

  @override
  String get exitPlayerMessage =>
      'Si sales ahora, se detendrá la reproducción actual.';

  @override
  String get continueWatching => 'Continuar viendo';

  @override
  String get exit => 'Salir';

  @override
  String get follow => 'Seguir';

  @override
  String get following => 'Siguiendo';

  @override
  String get contentPreferencesNotif =>
      'Preferencias de contenido para notificaciones';
}
