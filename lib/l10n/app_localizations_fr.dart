// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'MovieMemory';

  @override
  String get discover => 'Découvrir';

  @override
  String get search => 'Rechercher';

  @override
  String get searchHint => 'Rechercher films, séries...';

  @override
  String get library => 'Collections';

  @override
  String get profile => 'Profil';

  @override
  String get myLibrary => 'Mes Collections';

  @override
  String get watchLater => 'À voir';

  @override
  String get watched => 'Vus';

  @override
  String get favorites => 'Favoris';

  @override
  String get customLists => 'Mes Listes';

  @override
  String get listsNav => 'Listes';

  @override
  String get createList => 'Créer une liste';

  @override
  String get createListTitle => 'Nouvelle liste';

  @override
  String get listName => 'Nom de la liste';

  @override
  String get listDescription => 'Description (optionnelle)';

  @override
  String get cancel => 'Annuler';

  @override
  String get create => 'Créer';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get confirm => 'Confirmer';

  @override
  String get close => 'Fermer';

  @override
  String get deleteListTitle => 'Supprimer la liste';

  @override
  String deleteListMessage(Object name) {
    return 'Supprimer \"$name\"?';
  }

  @override
  String get deleteItemTitle => 'Supprimer l\'élément';

  @override
  String deleteItemMessage(Object name) {
    return 'Supprimer \"$name\" de cette liste?';
  }

  @override
  String get saveChangesTitle => 'Enregistrer les modifications';

  @override
  String get saveChangesMessage => 'Enregistrer les modifications effectuées?';

  @override
  String get emptyList => 'Cette liste est vide';

  @override
  String itemsCount(Object count) {
    return '$count éléments';
  }

  @override
  String get noResults => 'Aucun résultat dans cette catégorie';

  @override
  String get nothingHere => 'Rien ici pour l\'instant';

  @override
  String get tryOtherCategory => 'Essayez de sélectionner une autre catégorie';

  @override
  String get searchAndAdd =>
      'Recherchez des films, des séries et d\'autres contenus, organisez vos listes et partagez vos découvertes avec la communauté.';

  @override
  String get createFirstList => 'Créez votre première liste personnalisée';

  @override
  String get all => 'Tous';

  @override
  String get movie => 'Film';

  @override
  String get series => 'Série';

  @override
  String get anime => 'Anime';

  @override
  String get cartoon => 'Dessin animé';

  @override
  String get documentary => 'Documentaire';

  @override
  String get concert => 'Concert';

  @override
  String get other => 'Autre';

  @override
  String get noSynopsis => 'Aucun synopsis disponible';

  @override
  String get inYourLibrary => 'Dans vos collections';

  @override
  String get actions => 'Actions';

  @override
  String get addToWatchLater => 'À voir';

  @override
  String get markAsWatched => 'Déjà vu';

  @override
  String get addToFavorites => 'Ajouter aux favoris';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String get moveToWatchLater => 'Déplacer vers À voir';

  @override
  String get markAsWatchedAction => 'Marquer comme vu';

  @override
  String get removeFromLibrary => 'Retirer des collections';

  @override
  String get addedToFavorites => 'Ajouté aux favoris';

  @override
  String get addedToWatchLater => 'Ajouté à À voir';

  @override
  String get markedAsWatched => 'Marqué comme vu';

  @override
  String get addedToLibrary => 'Ajouté aux collections';

  @override
  String get removedFromLibrary => 'Retiré des collections';

  @override
  String get errorLoading => 'Erreur de chargement';

  @override
  String get error => 'Erreur';

  @override
  String get loggedInAs => 'Connecté avec Google';

  @override
  String get memberSince => 'Membre depuis';

  @override
  String get total => 'Total';

  @override
  String get viewed => 'Vus';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logoutTitle => 'Voulez-vous vous déconnecter?';

  @override
  String get logoutMessage =>
      'Vous devrez vous reconnecter pour accéder à votre compte.';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get age => 'Âge';

  @override
  String get email => 'Email';

  @override
  String get gender => 'Genre';

  @override
  String get bio => 'Biographie';

  @override
  String get photoURL => 'URL de la photo de profil';

  @override
  String get male => 'Masculin';

  @override
  String get female => 'Féminin';

  @override
  String get nonBinary => 'Non-binaire';

  @override
  String get preferNotToSay => 'Je préfère ne pas dire';

  @override
  String get otherGender => 'Autre';

  @override
  String get profileUpdated => 'Profil mis à jour avec succès';

  @override
  String get profileUpdateError => 'Erreur lors de la mise à jour du profil';

  @override
  String get language => 'Langue';

  @override
  String get spanish => 'Espagnol';

  @override
  String get english => 'Anglais';

  @override
  String get portuguese => 'Portugais';

  @override
  String get italian => 'Italien';

  @override
  String get french => 'Français';

  @override
  String get russian => 'Russe';

  @override
  String get korean => 'Coréen';

  @override
  String get japanese => 'Japonais';

  @override
  String get chinese => 'Chinois';

  @override
  String get share => 'Partager';

  @override
  String shareMovie(Object title, Object type) {
    return 'Regardez ce $type: $title';
  }

  @override
  String shareMovieDescription(Object overview) {
    return '$overview';
  }

  @override
  String shareList(Object name) {
    return 'Liste: $name';
  }

  @override
  String shareListDescription(Object count, Object description) {
    return '$description\n$count éléments sur MovieMemory';
  }

  @override
  String shareListItems(Object name) {
    return 'Contenu dans $name:';
  }

  @override
  String get addToList => 'Ajouter à la liste';

  @override
  String get addToListTitle => 'Ajouter à la liste';

  @override
  String get selectList => 'Sélectionnez une liste';

  @override
  String get addedToList => 'Ajouté à la liste';

  @override
  String get editList => 'Modifier la liste';

  @override
  String get editListTitle => 'Modifier la liste';

  @override
  String get newFieldRequired => 'Ce champ est requis';

  @override
  String get fieldRequired => 'Ce champ est requis';

  @override
  String get invalidEmail => 'Email invalide';

  @override
  String get ageRange => 'Doit être entre 0 et 150';

  @override
  String get saveConfirmation => 'Enregistrer les modifications?';

  @override
  String get typeMovie => 'film';

  @override
  String get typeSeries => 'série';

  @override
  String get markAsWatchedShort => 'Vu';

  @override
  String get favoriteShort => 'Favori';

  @override
  String get signOut => 'Déconnexion';

  @override
  String get loading => 'Chargement...';

  @override
  String get retry => 'Réessayer';

  @override
  String get noItemsInList => 'Aucun élément dans cette liste';

  @override
  String get listInfo => 'Informations de la liste';

  @override
  String get searchResults => 'Résultats de recherche';

  @override
  String get user => 'Utilisateur';

  @override
  String get trending => 'Tendances du jour';

  @override
  String get nowPlaying => 'Actuellement au cinéma';

  @override
  String get popularMovies => 'Films populaires';

  @override
  String get popularTv => 'Séries populaires';

  @override
  String get topRated => 'Les mieux notés';

  @override
  String get loginSubtitle =>
      'Plateforme pour découvrir, organiser et profiter du contenu multimédia.';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get or => 'ou';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get signIn => 'Se connecter';

  @override
  String get noAccount => 'Pas de compte ?';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get googleSignInError => 'Erreur de connexion avec Google';

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs';

  @override
  String get verifyEmailFirst =>
      'Vous devez vérifier votre email avant de vous connecter';

  @override
  String get wrongCredentials => 'Identifiants incorrects';

  @override
  String get loginError => 'Erreur de connexion';

  @override
  String get enterEmailFirst => 'Entrez d\'abord votre email';

  @override
  String get recoveryEmailSent => 'Email de récupération envoyé';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerSubtitle =>
      'Gérez vos collections, créez des listes personnalisées et partagez.';

  @override
  String get nameLabel => 'Prénom';

  @override
  String get lastNameLabel => 'Nom';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get logIn => 'Connexion';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get registrationSuccess => 'Inscription réussie';

  @override
  String get confirmationSent =>
      'Lien de confirmation envoyé à votre email. Vérifiez votre boîte de réception ou vos spams.';

  @override
  String get accept => 'ACCEPTER';

  @override
  String get completeAllFields => 'Complétez tous les champs';

  @override
  String get mustBe18 => 'Vous devez avoir au moins 18 ans';

  @override
  String get passwordsDontMatch => 'Les mots de passe ne correspondent pas';

  @override
  String minPasswordLength(Object length) {
    return 'Le mot de passe doit contenir au moins $length caractères';
  }

  @override
  String get emailAlreadyInUse => 'Email déjà utilisé';

  @override
  String get checkYourEmail => 'Vérifiez vos emails !';

  @override
  String get verificationSentTo =>
      'Nous avons envoyé un lien de vérification à :';

  @override
  String get clickToActivate =>
      'Cliquez sur le lien dans l\'email pour activer votre compte et vous connecter.';

  @override
  String get noEmailCheckSpam =>
      'Vous ne voyez pas l\'email ? Vérifiez vos spams ou courriers indésirables.';

  @override
  String get goToLogin => 'Aller à la connexion';

  @override
  String get yourPreferences => 'Vos préférences';

  @override
  String get selectFavoriteGenres =>
      'Sélectionnez vos genres préférés pour recevoir des recommandations personnalisées';

  @override
  String get favoriteGenres => 'Genres favoris';

  @override
  String get contentTypes => 'Types de contenu';

  @override
  String get start => 'Commencer';

  @override
  String get skip => 'Passer';

  @override
  String get synopsis => 'Synopsis';

  @override
  String get movedToWatchLater => 'Déplacé vers À voir plus tard';

  @override
  String get minutesLabel => 'min';

  @override
  String get searchHintEmpty => 'Tapez quelque chose pour rechercher';

  @override
  String get noResultsSearch => 'Aucun résultat';

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
      'MovieMemory est votre plateforme personnelle pour découvrir, organiser et profiter du contenu multimédia. Gérez vos collections, créez des listes personnalisées et partagez avec la communauté.';

  @override
  String get developer => 'Developer';

  @override
  String get credits =>
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';

  @override
  String get releaseDate => 'Date de sortie';

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
  String get soundSettings => 'Paramètres du son';

  @override
  String get openAppSound => 'Son de démarrage de l\'app';

  @override
  String get clickSound => 'Son du clic';

  @override
  String get addSound => 'Son d\'ajout';

  @override
  String get confirmSound => 'Son de confirmation';

  @override
  String get removeSound => 'Son de suppression';

  @override
  String get errorSound => 'Son d\'erreur';

  @override
  String get freesoundCredit => 'Sons sous licence Free Commons';

  @override
  String get notificationSound => 'Son de notification';

  @override
  String get supportEmail => 'Email de support';

  @override
  String get silentMode => 'Mode silencieux';

  @override
  String get silentModeDesc => 'Désactive tous les sons de l\'application';

  @override
  String get playbackLanguage => 'Langue de lecture';

  @override
  String get defaultAudioLanguage => 'Langue audio par défaut';

  @override
  String get defaultSubtitleLanguage => 'Langue des sous-titres par défaut';

  @override
  String get appLanguage => 'Langue de l\'application';

  @override
  String get systemLanguage => 'Langue du système';

  @override
  String get originalLanguage => 'Langue originale';

  @override
  String get subtitlesDisabled => 'Désactivé';

  @override
  String get exitPlayerTitle => 'Voulez-vous quitter le lecteur?';

  @override
  String get exitPlayerMessage =>
      'Si vous quittez maintenant, la lecture en cours sera arrêtée.';

  @override
  String get continueWatching => 'Continuer à regarder';

  @override
  String get exit => 'Quitter';

  @override
  String get follow => 'Suivre';

  @override
  String get following => 'Abonné';

  @override
  String get contentPreferencesNotif =>
      'Préférences de contenu pour les notifications';
}
