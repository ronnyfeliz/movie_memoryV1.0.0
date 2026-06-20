import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'MovieMemory'**
  String get appTitle;

  /// No description provided for @discover.
  ///
  /// In es, this message translates to:
  /// **'Descubrir'**
  String get discover;

  /// No description provided for @search.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar películas, series...'**
  String get searchHint;

  /// No description provided for @library.
  ///
  /// In es, this message translates to:
  /// **'Librería'**
  String get library;

  /// No description provided for @profile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @myLibrary.
  ///
  /// In es, this message translates to:
  /// **'Mi Librería'**
  String get myLibrary;

  /// No description provided for @watchLater.
  ///
  /// In es, this message translates to:
  /// **'Ver después'**
  String get watchLater;

  /// No description provided for @watched.
  ///
  /// In es, this message translates to:
  /// **'Vistos'**
  String get watched;

  /// No description provided for @favorites.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get favorites;

  /// No description provided for @customLists.
  ///
  /// In es, this message translates to:
  /// **'Mis Listas'**
  String get customLists;

  /// No description provided for @listsNav.
  ///
  /// In es, this message translates to:
  /// **'Listas'**
  String get listsNav;

  /// No description provided for @createList.
  ///
  /// In es, this message translates to:
  /// **'Crear lista'**
  String get createList;

  /// No description provided for @createListTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva lista'**
  String get createListTitle;

  /// No description provided for @listName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la lista'**
  String get listName;

  /// No description provided for @listDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get listDescription;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get create;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @deleteListTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar lista'**
  String get deleteListTitle;

  /// No description provided for @deleteListMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"?'**
  String deleteListMessage(Object name);

  /// No description provided for @deleteItemTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar ficha'**
  String get deleteItemTitle;

  /// No description provided for @deleteItemMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\" de esta lista?'**
  String deleteItemMessage(Object name);

  /// No description provided for @saveChangesTitle.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get saveChangesTitle;

  /// No description provided for @saveChangesMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Guardar los cambios realizados?'**
  String get saveChangesMessage;

  /// No description provided for @emptyList.
  ///
  /// In es, this message translates to:
  /// **'Esta lista está vacía'**
  String get emptyList;

  /// No description provided for @itemsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} items'**
  String itemsCount(Object count);

  /// No description provided for @noResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados en esta categoría'**
  String get noResults;

  /// No description provided for @nothingHere.
  ///
  /// In es, this message translates to:
  /// **'Nada aquí todavía'**
  String get nothingHere;

  /// No description provided for @tryOtherCategory.
  ///
  /// In es, this message translates to:
  /// **'Prueba seleccionando otra categoría'**
  String get tryOtherCategory;

  /// No description provided for @searchAndAdd.
  ///
  /// In es, this message translates to:
  /// **'Busca películas, series y otros contenidos, organiza tus listas y comparte tus descubrimientos con la comunidad.'**
  String get searchAndAdd;

  /// No description provided for @createFirstList.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primera lista personalizada'**
  String get createFirstList;

  /// No description provided for @all.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get all;

  /// No description provided for @movie.
  ///
  /// In es, this message translates to:
  /// **'Película'**
  String get movie;

  /// No description provided for @series.
  ///
  /// In es, this message translates to:
  /// **'Serie'**
  String get series;

  /// No description provided for @anime.
  ///
  /// In es, this message translates to:
  /// **'Anime'**
  String get anime;

  /// No description provided for @cartoon.
  ///
  /// In es, this message translates to:
  /// **'Caricatura'**
  String get cartoon;

  /// No description provided for @documentary.
  ///
  /// In es, this message translates to:
  /// **'Documental'**
  String get documentary;

  /// No description provided for @concert.
  ///
  /// In es, this message translates to:
  /// **'Concierto'**
  String get concert;

  /// No description provided for @other.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get other;

  /// No description provided for @noSynopsis.
  ///
  /// In es, this message translates to:
  /// **'Sin sinopsis disponible'**
  String get noSynopsis;

  /// No description provided for @inYourLibrary.
  ///
  /// In es, this message translates to:
  /// **'En tu librería'**
  String get inYourLibrary;

  /// No description provided for @actions.
  ///
  /// In es, this message translates to:
  /// **'Acciones'**
  String get actions;

  /// No description provided for @addToWatchLater.
  ///
  /// In es, this message translates to:
  /// **'Ver después'**
  String get addToWatchLater;

  /// No description provided for @markAsWatched.
  ///
  /// In es, this message translates to:
  /// **'Ya visto'**
  String get markAsWatched;

  /// No description provided for @addToFavorites.
  ///
  /// In es, this message translates to:
  /// **'Agregar a favoritos'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In es, this message translates to:
  /// **'Quitar de favoritos'**
  String get removeFromFavorites;

  /// No description provided for @moveToWatchLater.
  ///
  /// In es, this message translates to:
  /// **'Mover a Ver después'**
  String get moveToWatchLater;

  /// No description provided for @markAsWatchedAction.
  ///
  /// In es, this message translates to:
  /// **'Marcar como visto'**
  String get markAsWatchedAction;

  /// No description provided for @removeFromLibrary.
  ///
  /// In es, this message translates to:
  /// **'Eliminar de la librería'**
  String get removeFromLibrary;

  /// No description provided for @addedToFavorites.
  ///
  /// In es, this message translates to:
  /// **'Agregado a favoritos'**
  String get addedToFavorites;

  /// No description provided for @addedToWatchLater.
  ///
  /// In es, this message translates to:
  /// **'Agregado a Ver después'**
  String get addedToWatchLater;

  /// No description provided for @markedAsWatched.
  ///
  /// In es, this message translates to:
  /// **'Marcado como visto'**
  String get markedAsWatched;

  /// No description provided for @addedToLibrary.
  ///
  /// In es, this message translates to:
  /// **'Agregado a la librería'**
  String get addedToLibrary;

  /// No description provided for @removedFromLibrary.
  ///
  /// In es, this message translates to:
  /// **'Eliminado de la librería'**
  String get removedFromLibrary;

  /// No description provided for @errorLoading.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar'**
  String get errorLoading;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loggedInAs.
  ///
  /// In es, this message translates to:
  /// **'Iniciaste sesión con Google'**
  String get loggedInAs;

  /// No description provided for @memberSince.
  ///
  /// In es, this message translates to:
  /// **'Miembro desde'**
  String get memberSince;

  /// No description provided for @total.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @viewed.
  ///
  /// In es, this message translates to:
  /// **'Vistos'**
  String get viewed;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// No description provided for @logoutTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas cerrar sesión?'**
  String get logoutTitle;

  /// No description provided for @logoutMessage.
  ///
  /// In es, this message translates to:
  /// **'Tendrás que volver a iniciar sesión para acceder a tu cuenta.'**
  String get logoutMessage;

  /// No description provided for @editProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editProfile;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settings;

  /// No description provided for @firstName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In es, this message translates to:
  /// **'Apellidos'**
  String get lastName;

  /// No description provided for @age.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get age;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// No description provided for @gender.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get gender;

  /// No description provided for @bio.
  ///
  /// In es, this message translates to:
  /// **'Biografía'**
  String get bio;

  /// No description provided for @photoURL.
  ///
  /// In es, this message translates to:
  /// **'URL de foto de perfil'**
  String get photoURL;

  /// No description provided for @male.
  ///
  /// In es, this message translates to:
  /// **'Masculino'**
  String get male;

  /// No description provided for @female.
  ///
  /// In es, this message translates to:
  /// **'Femenino'**
  String get female;

  /// No description provided for @nonBinary.
  ///
  /// In es, this message translates to:
  /// **'No binario'**
  String get nonBinary;

  /// No description provided for @preferNotToSay.
  ///
  /// In es, this message translates to:
  /// **'Prefiero no decirlo'**
  String get preferNotToSay;

  /// No description provided for @otherGender.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get otherGender;

  /// No description provided for @profileUpdated.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado correctamente'**
  String get profileUpdated;

  /// No description provided for @profileUpdateError.
  ///
  /// In es, this message translates to:
  /// **'Error al actualizar el perfil'**
  String get profileUpdateError;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get english;

  /// No description provided for @portuguese.
  ///
  /// In es, this message translates to:
  /// **'Portugués'**
  String get portuguese;

  /// No description provided for @italian.
  ///
  /// In es, this message translates to:
  /// **'Italiano'**
  String get italian;

  /// No description provided for @french.
  ///
  /// In es, this message translates to:
  /// **'Francés'**
  String get french;

  /// No description provided for @russian.
  ///
  /// In es, this message translates to:
  /// **'Ruso'**
  String get russian;

  /// No description provided for @korean.
  ///
  /// In es, this message translates to:
  /// **'Coreano'**
  String get korean;

  /// No description provided for @japanese.
  ///
  /// In es, this message translates to:
  /// **'Japonés'**
  String get japanese;

  /// No description provided for @chinese.
  ///
  /// In es, this message translates to:
  /// **'Chino'**
  String get chinese;

  /// No description provided for @share.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get share;

  /// No description provided for @shareMovie.
  ///
  /// In es, this message translates to:
  /// **'Mira esta {type}: {title}'**
  String shareMovie(Object title, Object type);

  /// No description provided for @shareMovieDescription.
  ///
  /// In es, this message translates to:
  /// **'{overview}'**
  String shareMovieDescription(Object overview);

  /// No description provided for @shareList.
  ///
  /// In es, this message translates to:
  /// **'Lista: {name}'**
  String shareList(Object name);

  /// No description provided for @shareListDescription.
  ///
  /// In es, this message translates to:
  /// **'{description}\n{count} items en MovieMemory'**
  String shareListDescription(Object count, Object description);

  /// No description provided for @shareListItems.
  ///
  /// In es, this message translates to:
  /// **'Contenido en {name}:'**
  String shareListItems(Object name);

  /// No description provided for @addToList.
  ///
  /// In es, this message translates to:
  /// **'Agregar a lista'**
  String get addToList;

  /// No description provided for @addToListTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar a lista'**
  String get addToListTitle;

  /// No description provided for @selectList.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una lista'**
  String get selectList;

  /// No description provided for @addedToList.
  ///
  /// In es, this message translates to:
  /// **'Agregado a la lista'**
  String get addedToList;

  /// No description provided for @editList.
  ///
  /// In es, this message translates to:
  /// **'Editar lista'**
  String get editList;

  /// No description provided for @editListTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar lista'**
  String get editListTitle;

  /// No description provided for @newFieldRequired.
  ///
  /// In es, this message translates to:
  /// **'Este campo es requerido'**
  String get newFieldRequired;

  /// No description provided for @fieldRequired.
  ///
  /// In es, this message translates to:
  /// **'Este campo es requerido'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico inválido'**
  String get invalidEmail;

  /// No description provided for @ageRange.
  ///
  /// In es, this message translates to:
  /// **'Debe ser entre 0 y 150'**
  String get ageRange;

  /// No description provided for @saveConfirmation.
  ///
  /// In es, this message translates to:
  /// **'¿Guardar los cambios?'**
  String get saveConfirmation;

  /// No description provided for @typeMovie.
  ///
  /// In es, this message translates to:
  /// **'película'**
  String get typeMovie;

  /// No description provided for @typeSeries.
  ///
  /// In es, this message translates to:
  /// **'serie'**
  String get typeSeries;

  /// No description provided for @markAsWatchedShort.
  ///
  /// In es, this message translates to:
  /// **'Visto'**
  String get markAsWatchedShort;

  /// No description provided for @favoriteShort.
  ///
  /// In es, this message translates to:
  /// **'Favorito'**
  String get favoriteShort;

  /// No description provided for @signOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get signOut;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @noItemsInList.
  ///
  /// In es, this message translates to:
  /// **'No hay items en esta lista'**
  String get noItemsInList;

  /// No description provided for @listInfo.
  ///
  /// In es, this message translates to:
  /// **'Información de la lista'**
  String get listInfo;

  /// No description provided for @searchResults.
  ///
  /// In es, this message translates to:
  /// **'Resultados de búsqueda'**
  String get searchResults;

  /// No description provided for @user.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get user;

  /// No description provided for @trending.
  ///
  /// In es, this message translates to:
  /// **'Tendencias hoy'**
  String get trending;

  /// No description provided for @nowPlaying.
  ///
  /// In es, this message translates to:
  /// **'Ahora en cines'**
  String get nowPlaying;

  /// No description provided for @popularMovies.
  ///
  /// In es, this message translates to:
  /// **'Películas populares'**
  String get popularMovies;

  /// No description provided for @popularTv.
  ///
  /// In es, this message translates to:
  /// **'Series populares'**
  String get popularTv;

  /// No description provided for @topRated.
  ///
  /// In es, this message translates to:
  /// **'Mejor calificadas'**
  String get topRated;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Plataforma para descubrir, organizar y disfrutar contenido multimedia.'**
  String get loginSubtitle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get continueWithGoogle;

  /// No description provided for @or.
  ///
  /// In es, this message translates to:
  /// **'o'**
  String get or;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordLabel;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In es, this message translates to:
  /// **'Ingresar'**
  String get signIn;

  /// No description provided for @noAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get signUp;

  /// No description provided for @googleSignInError.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar con Google'**
  String get googleSignInError;

  /// No description provided for @fillAllFields.
  ///
  /// In es, this message translates to:
  /// **'Completa todos los campos'**
  String get fillAllFields;

  /// No description provided for @verifyEmailFirst.
  ///
  /// In es, this message translates to:
  /// **'Debes verificar tu correo antes de iniciar sesión'**
  String get verifyEmailFirst;

  /// No description provided for @wrongCredentials.
  ///
  /// In es, this message translates to:
  /// **'Credenciales incorrectas'**
  String get wrongCredentials;

  /// No description provided for @loginError.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión'**
  String get loginError;

  /// No description provided for @enterEmailFirst.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo primero'**
  String get enterEmailFirst;

  /// No description provided for @recoveryEmailSent.
  ///
  /// In es, this message translates to:
  /// **'Correo de recuperación enviado'**
  String get recoveryEmailSent;

  /// No description provided for @registerTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestiona tu librería, crea listas personalizadas y comparte.'**
  String get registerSubtitle;

  /// No description provided for @nameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get nameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Apellido'**
  String get lastNameLabel;

  /// No description provided for @confirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta?'**
  String get alreadyHaveAccount;

  /// No description provided for @logIn.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get logIn;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get createAccount;

  /// No description provided for @registrationSuccess.
  ///
  /// In es, this message translates to:
  /// **'Registro exitoso'**
  String get registrationSuccess;

  /// No description provided for @confirmationSent.
  ///
  /// In es, this message translates to:
  /// **'Enlace de confirmación enviado a su correo. Revise su bandeja de entrada o la carpeta de spam.'**
  String get confirmationSent;

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'ACEPTAR'**
  String get accept;

  /// No description provided for @completeAllFields.
  ///
  /// In es, this message translates to:
  /// **'Completa todos los campos'**
  String get completeAllFields;

  /// No description provided for @mustBe18.
  ///
  /// In es, this message translates to:
  /// **'Debes tener al menos 18 años para registrarte'**
  String get mustBe18;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDontMatch;

  /// No description provided for @minPasswordLength.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos {length} caracteres'**
  String minPasswordLength(Object length);

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In es, this message translates to:
  /// **'Correo ya en uso'**
  String get emailAlreadyInUse;

  /// No description provided for @checkYourEmail.
  ///
  /// In es, this message translates to:
  /// **'¡Revisa tu correo!'**
  String get checkYourEmail;

  /// No description provided for @verificationSentTo.
  ///
  /// In es, this message translates to:
  /// **'Enviamos un enlace de verificación a:'**
  String get verificationSentTo;

  /// No description provided for @clickToActivate.
  ///
  /// In es, this message translates to:
  /// **'Haz click en el enlace del correo para activar tu cuenta e iniciar sesión.'**
  String get clickToActivate;

  /// No description provided for @noEmailCheckSpam.
  ///
  /// In es, this message translates to:
  /// **'¿No ves el correo? Revisa tu carpeta de spam o correo no deseado.'**
  String get noEmailCheckSpam;

  /// No description provided for @goToLogin.
  ///
  /// In es, this message translates to:
  /// **'Ir al Login'**
  String get goToLogin;

  /// No description provided for @yourPreferences.
  ///
  /// In es, this message translates to:
  /// **'Tus gustos'**
  String get yourPreferences;

  /// No description provided for @selectFavoriteGenres.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tus géneros favoritos para recibir recomendaciones personalizadas'**
  String get selectFavoriteGenres;

  /// No description provided for @favoriteGenres.
  ///
  /// In es, this message translates to:
  /// **'Géneros favoritos'**
  String get favoriteGenres;

  /// No description provided for @contentTypes.
  ///
  /// In es, this message translates to:
  /// **'Tipos de contenido'**
  String get contentTypes;

  /// No description provided for @start.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get start;

  /// No description provided for @skip.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get skip;

  /// No description provided for @synopsis.
  ///
  /// In es, this message translates to:
  /// **'Sinopsis'**
  String get synopsis;

  /// No description provided for @movedToWatchLater.
  ///
  /// In es, this message translates to:
  /// **'Movido a Ver después'**
  String get movedToWatchLater;

  /// No description provided for @minutesLabel.
  ///
  /// In es, this message translates to:
  /// **'min'**
  String get minutesLabel;

  /// No description provided for @searchHintEmpty.
  ///
  /// In es, this message translates to:
  /// **'Escribe algo para buscar'**
  String get searchHintEmpty;

  /// No description provided for @noResultsSearch.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get noResultsSearch;

  /// No description provided for @theme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get dark;

  /// No description provided for @systemTheme.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get systemTheme;

  /// No description provided for @about.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get about;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// No description provided for @appDescription.
  ///
  /// In es, this message translates to:
  /// **'MovieMemory es tu plataforma personal para descubrir, organizar y disfrutar contenido multimedia. Gestiona tu librería, crea listas personalizadas y comparte con la comunidad.'**
  String get appDescription;

  /// No description provided for @developer.
  ///
  /// In es, this message translates to:
  /// **'Desarrollador'**
  String get developer;

  /// No description provided for @credits.
  ///
  /// In es, this message translates to:
  /// **'Este producto usa la API de TMDB pero no está respaldado ni certificado por TMDB.'**
  String get credits;

  /// No description provided for @releaseDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de lanzamiento'**
  String get releaseDate;

  /// No description provided for @deleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro? Esta acción no se puede deshacer. Todos tus datos se eliminarán permanentemente.'**
  String get deleteAccountMessage;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In es, this message translates to:
  /// **'Esto eliminará permanentemente todos tus datos.'**
  String get deleteAccountConfirm;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @notificationType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de notificación'**
  String get notificationType;

  /// No description provided for @normal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @popup.
  ///
  /// In es, this message translates to:
  /// **'Pop-up'**
  String get popup;

  /// No description provided for @both.
  ///
  /// In es, this message translates to:
  /// **'Ambos'**
  String get both;

  /// No description provided for @soundSettings.
  ///
  /// In es, this message translates to:
  /// **'Configuración de sonido'**
  String get soundSettings;

  /// No description provided for @openAppSound.
  ///
  /// In es, this message translates to:
  /// **'Sonido de inicio'**
  String get openAppSound;

  /// No description provided for @clickSound.
  ///
  /// In es, this message translates to:
  /// **'Sonido de clic'**
  String get clickSound;

  /// No description provided for @addSound.
  ///
  /// In es, this message translates to:
  /// **'Sonido de agregar'**
  String get addSound;

  /// No description provided for @confirmSound.
  ///
  /// In es, this message translates to:
  /// **'Sonido de confirmar'**
  String get confirmSound;

  /// No description provided for @removeSound.
  ///
  /// In es, this message translates to:
  /// **'Sonido de eliminar'**
  String get removeSound;

  /// No description provided for @errorSound.
  ///
  /// In es, this message translates to:
  /// **'Sonido de error'**
  String get errorSound;

  /// No description provided for @freesoundCredit.
  ///
  /// In es, this message translates to:
  /// **'Sonidos bajo licencia Free Commons'**
  String get freesoundCredit;

  /// No description provided for @notificationSound.
  ///
  /// In es, this message translates to:
  /// **'Sonido de notificación'**
  String get notificationSound;

  /// No description provided for @supportEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo de soporte'**
  String get supportEmail;

  /// No description provided for @silentMode.
  ///
  /// In es, this message translates to:
  /// **'Modo silencioso'**
  String get silentMode;

  /// No description provided for @silentModeDesc.
  ///
  /// In es, this message translates to:
  /// **'Desactiva todos los sonidos de la aplicación'**
  String get silentModeDesc;

  /// No description provided for @playbackLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma de reproducción'**
  String get playbackLanguage;

  /// No description provided for @defaultAudioLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma de audio por defecto'**
  String get defaultAudioLanguage;

  /// No description provided for @defaultSubtitleLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma de subtítulos por defecto'**
  String get defaultSubtitleLanguage;

  /// No description provided for @appLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma de la app'**
  String get appLanguage;

  /// No description provided for @systemLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma del sistema'**
  String get systemLanguage;

  /// No description provided for @originalLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma original'**
  String get originalLanguage;

  /// No description provided for @subtitlesDisabled.
  ///
  /// In es, this message translates to:
  /// **'Desactivados'**
  String get subtitlesDisabled;

  /// No description provided for @exitPlayerTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas salir del reproductor?'**
  String get exitPlayerTitle;

  /// No description provided for @exitPlayerMessage.
  ///
  /// In es, this message translates to:
  /// **'Si sales ahora, se detendrá la reproducción actual.'**
  String get exitPlayerMessage;

  /// No description provided for @continueWatching.
  ///
  /// In es, this message translates to:
  /// **'Continuar viendo'**
  String get continueWatching;

  /// No description provided for @exit.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get exit;

  /// No description provided for @follow.
  ///
  /// In es, this message translates to:
  /// **'Seguir'**
  String get follow;

  /// No description provided for @following.
  ///
  /// In es, this message translates to:
  /// **'Siguiendo'**
  String get following;

  /// No description provided for @contentPreferencesNotif.
  ///
  /// In es, this message translates to:
  /// **'Preferencias de contenido para notificaciones'**
  String get contentPreferencesNotif;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'es',
        'fr',
        'it',
        'ja',
        'ko',
        'pt',
        'ru',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
