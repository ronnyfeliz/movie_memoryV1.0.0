// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'MovieMemory';

  @override
  String get discover => 'Scopri';

  @override
  String get search => 'Cerca';

  @override
  String get searchHint => 'Cerca film, serie...';

  @override
  String get library => 'Collezioni';

  @override
  String get profile => 'Profilo';

  @override
  String get myLibrary => 'Le mie Collezioni';

  @override
  String get watchLater => 'Da vedere';

  @override
  String get watched => 'Visti';

  @override
  String get favorites => 'Preferiti';

  @override
  String get customLists => 'Le Mie Liste';

  @override
  String get listsNav => 'Liste';

  @override
  String get createList => 'Crea lista';

  @override
  String get createListTitle => 'Nuova lista';

  @override
  String get listName => 'Nome della lista';

  @override
  String get listDescription => 'Descrizione (opzionale)';

  @override
  String get cancel => 'Annulla';

  @override
  String get create => 'Crea';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Elimina';

  @override
  String get edit => 'Modifica';

  @override
  String get confirm => 'Conferma';

  @override
  String get close => 'Chiudi';

  @override
  String get deleteListTitle => 'Elimina lista';

  @override
  String deleteListMessage(Object name) {
    return 'Eliminare \"$name\"?';
  }

  @override
  String get deleteItemTitle => 'Elimina elemento';

  @override
  String deleteItemMessage(Object name) {
    return 'Eliminare \"$name\" da questa lista?';
  }

  @override
  String get saveChangesTitle => 'Salva modifiche';

  @override
  String get saveChangesMessage => 'Salvare le modifiche apportate?';

  @override
  String get emptyList => 'Questa lista è vuota';

  @override
  String itemsCount(Object count) {
    return '$count elementi';
  }

  @override
  String get noResults => 'Nessun risultato in questa categoria';

  @override
  String get nothingHere => 'Ancora nulla qui';

  @override
  String get tryOtherCategory => 'Prova a selezionare un\'altra categoria';

  @override
  String get searchAndAdd =>
      'Cerca film, serie e altri contenuti, organizza le tue liste e condividi le tue scoperte con la comunità.';

  @override
  String get createFirstList => 'Crea la tua prima lista personalizzata';

  @override
  String get all => 'Tutti';

  @override
  String get movie => 'Film';

  @override
  String get series => 'Serie';

  @override
  String get anime => 'Anime';

  @override
  String get cartoon => 'Cartone';

  @override
  String get documentary => 'Documentario';

  @override
  String get concert => 'Concerto';

  @override
  String get other => 'Altro';

  @override
  String get noSynopsis => 'Sinossi non disponibile';

  @override
  String get inYourLibrary => 'Nelle tue collezioni';

  @override
  String get actions => 'Azioni';

  @override
  String get addToWatchLater => 'Da vedere';

  @override
  String get markAsWatched => 'Già visto';

  @override
  String get addToFavorites => 'Aggiungi ai preferiti';

  @override
  String get removeFromFavorites => 'Rimuovi dai preferiti';

  @override
  String get moveToWatchLater => 'Sposta in Da vedere';

  @override
  String get markAsWatchedAction => 'Segna come visto';

  @override
  String get removeFromLibrary => 'Rimuovi dalle collezioni';

  @override
  String get addedToFavorites => 'Aggiunto ai preferiti';

  @override
  String get addedToWatchLater => 'Aggiunto a Da vedere';

  @override
  String get markedAsWatched => 'Segnato come visto';

  @override
  String get addedToLibrary => 'Aggiunto alle collezioni';

  @override
  String get removedFromLibrary => 'Rimosso dalle collezioni';

  @override
  String get errorLoading => 'Errore di caricamento';

  @override
  String get error => 'Errore';

  @override
  String get loggedInAs => 'Accesso con Google';

  @override
  String get memberSince => 'Membro dal';

  @override
  String get total => 'Totale';

  @override
  String get viewed => 'Visti';

  @override
  String get logout => 'Esci';

  @override
  String get logoutTitle => 'Vuoi uscire dal tuo account?';

  @override
  String get logoutMessage =>
      'Dovrai effettuare nuovamente l\'accesso per accedere al tuo account.';

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get settings => 'Impostazioni';

  @override
  String get firstName => 'Nome';

  @override
  String get lastName => 'Cognome';

  @override
  String get age => 'Età';

  @override
  String get email => 'Email';

  @override
  String get gender => 'Genere';

  @override
  String get bio => 'Biografia';

  @override
  String get photoURL => 'URL foto profilo';

  @override
  String get male => 'Maschile';

  @override
  String get female => 'Femminile';

  @override
  String get nonBinary => 'Non binario';

  @override
  String get preferNotToSay => 'Preferisco non dirlo';

  @override
  String get otherGender => 'Altro';

  @override
  String get profileUpdated => 'Profilo aggiornato con successo';

  @override
  String get profileUpdateError => 'Errore nell\'aggiornamento del profilo';

  @override
  String get language => 'Lingua';

  @override
  String get spanish => 'Spagnolo';

  @override
  String get english => 'Inglese';

  @override
  String get portuguese => 'Portoghese';

  @override
  String get italian => 'Italiano';

  @override
  String get french => 'Francese';

  @override
  String get russian => 'Russo';

  @override
  String get korean => 'Coreano';

  @override
  String get japanese => 'Giapponese';

  @override
  String get chinese => 'Cinese';

  @override
  String get share => 'Condividi';

  @override
  String shareMovie(Object title, Object type) {
    return 'Guarda questo $type: $title';
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
    return '$description\n$count elementi su MovieMemory';
  }

  @override
  String shareListItems(Object name) {
    return 'Contenuti in $name:';
  }

  @override
  String get addToList => 'Aggiungi alla lista';

  @override
  String get addToListTitle => 'Aggiungi alla lista';

  @override
  String get selectList => 'Seleziona una lista';

  @override
  String get addedToList => 'Aggiunto alla lista';

  @override
  String get editList => 'Modifica lista';

  @override
  String get editListTitle => 'Modifica lista';

  @override
  String get newFieldRequired => 'Questo campo è obbligatorio';

  @override
  String get fieldRequired => 'Questo campo è obbligatorio';

  @override
  String get invalidEmail => 'Email non valida';

  @override
  String get ageRange => 'Deve essere tra 0 e 150';

  @override
  String get saveConfirmation => 'Salvare le modifiche?';

  @override
  String get typeMovie => 'film';

  @override
  String get typeSeries => 'serie';

  @override
  String get markAsWatchedShort => 'Visto';

  @override
  String get favoriteShort => 'Preferito';

  @override
  String get signOut => 'Esci';

  @override
  String get loading => 'Caricamento...';

  @override
  String get retry => 'Riprova';

  @override
  String get noItemsInList => 'Nessun elemento in questa lista';

  @override
  String get listInfo => 'Informazioni lista';

  @override
  String get searchResults => 'Risultati ricerca';

  @override
  String get user => 'Utente';

  @override
  String get trending => 'Tendenze oggi';

  @override
  String get nowPlaying => 'Al cinema';

  @override
  String get popularMovies => 'Film popolari';

  @override
  String get popularTv => 'Serie popolari';

  @override
  String get topRated => 'Più votati';

  @override
  String get loginSubtitle =>
      'Piattaforma per scoprire, organizzare e godersi contenuti multimediali.';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get or => 'o';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get signIn => 'Accedi';

  @override
  String get noAccount => 'Non hai un account?';

  @override
  String get signUp => 'Registrati';

  @override
  String get googleSignInError => 'Errore di accesso con Google';

  @override
  String get fillAllFields => 'Compila tutti i campi';

  @override
  String get verifyEmailFirst =>
      'Devi verificare la tua email prima di accedere';

  @override
  String get wrongCredentials => 'Credenziali errate';

  @override
  String get loginError => 'Errore di accesso';

  @override
  String get enterEmailFirst => 'Inserisci prima la tua email';

  @override
  String get recoveryEmailSent => 'Email di recupero inviata';

  @override
  String get registerTitle => 'Crea account';

  @override
  String get registerSubtitle =>
      'Gestisci le tue collezioni, crea liste personalizzate e condividi.';

  @override
  String get nameLabel => 'Nome';

  @override
  String get lastNameLabel => 'Cognome';

  @override
  String get confirmPassword => 'Conferma password';

  @override
  String get alreadyHaveAccount => 'Hai già un account?';

  @override
  String get logIn => 'Accedi';

  @override
  String get createAccount => 'Crea account';

  @override
  String get registrationSuccess => 'Registrazione completata';

  @override
  String get confirmationSent =>
      'Link di conferma inviato alla tua email. Controlla la posta in arrivo o la cartella spam.';

  @override
  String get accept => 'ACCETTA';

  @override
  String get completeAllFields => 'Compila tutti i campi';

  @override
  String get mustBe18 => 'Devi avere almeno 18 anni';

  @override
  String get passwordsDontMatch => 'Le password non corrispondono';

  @override
  String minPasswordLength(Object length) {
    return 'La password deve contenere almeno $length caratteri';
  }

  @override
  String get emailAlreadyInUse => 'Email già in uso';

  @override
  String get checkYourEmail => 'Controlla la tua email!';

  @override
  String get verificationSentTo => 'Abbiamo inviato un link di verifica a:';

  @override
  String get clickToActivate =>
      'Clicca il link nell\'email per attivare il tuo account e accedere.';

  @override
  String get noEmailCheckSpam =>
      'Non vedi l\'email? Controlla la cartella spam o posta indesiderata.';

  @override
  String get goToLogin => 'Vai al Login';

  @override
  String get yourPreferences => 'Le tue preferenze';

  @override
  String get selectFavoriteGenres =>
      'Seleziona i tuoi generi preferiti per ricevere raccomandazioni personalizzate';

  @override
  String get favoriteGenres => 'Generi preferiti';

  @override
  String get contentTypes => 'Tipi di contenuto';

  @override
  String get start => 'Inizia';

  @override
  String get skip => 'Salta';

  @override
  String get synopsis => 'Sinossi';

  @override
  String get movedToWatchLater => 'Spostato in Da vedere';

  @override
  String get minutesLabel => 'min';

  @override
  String get searchHintEmpty => 'Scrivi qualcosa per cercare';

  @override
  String get noResultsSearch => 'Nessun risultato';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get systemTheme => 'System';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get appDescription =>
      'MovieMemory è la tua piattaforma personale per scoprire, organizzare e godersi contenuti multimediali. Gestisci le tue collezioni, crea liste personalizzate e condividi con la comunità.';

  @override
  String get developer => 'Developer';

  @override
  String get credits =>
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';

  @override
  String get releaseDate => 'Data di rilascio';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountMessage =>
      'Are you sure? This action cannot be undone. All your data will be permanently deleted.';

  @override
  String get deleteAccountConfirm =>
      'This will permanently delete all your data.';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationType => 'Notification type';

  @override
  String get normal => 'Normal';

  @override
  String get popup => 'Popup';

  @override
  String get both => 'Both';

  @override
  String get soundSettings => 'Impostazioni audio';

  @override
  String get openAppSound => 'Suono di avvio dell\'app';

  @override
  String get clickSound => 'Suono del clic';

  @override
  String get addSound => 'Suono di aggiunta';

  @override
  String get confirmSound => 'Suono di conferma';

  @override
  String get removeSound => 'Suono di rimozione';

  @override
  String get errorSound => 'Suono di errore';

  @override
  String get freesoundCredit => 'Suoni sotto licenza Free Commons';

  @override
  String get notificationSound => 'Suono di notifica';

  @override
  String get supportEmail => 'Email di supporto';

  @override
  String get silentMode => 'Modalità silenziosa';

  @override
  String get silentModeDesc => 'Disattiva tutti i suoni dell\'applicazione';

  @override
  String get playbackLanguage => 'Lingua di riproduzione';

  @override
  String get defaultAudioLanguage => 'Lingua audio predefinita';

  @override
  String get defaultSubtitleLanguage => 'Lingua sottotitoli predefinita';

  @override
  String get appLanguage => 'Lingua dell\'app';

  @override
  String get systemLanguage => 'Lingua del sistema';

  @override
  String get originalLanguage => 'Lingua originale';

  @override
  String get subtitlesDisabled => 'Disabilitato';

  @override
  String get exitPlayerTitle => 'Vuoi uscire dal lettore?';

  @override
  String get exitPlayerMessage =>
      'Se esci ora, la riproduzione corrente verrà interrotta.';

  @override
  String get continueWatching => 'Continua a guardare';

  @override
  String get exit => 'Esci';

  @override
  String get follow => 'Segui';

  @override
  String get following => 'Seguito';

  @override
  String get contentPreferencesNotif =>
      'Preferenze di contenuto per le notifiche';
}
