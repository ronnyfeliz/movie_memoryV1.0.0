// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MovieMemory';

  @override
  String get discover => 'Discover';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search movies, series...';

  @override
  String get library => 'Collections';

  @override
  String get profile => 'Profile';

  @override
  String get myLibrary => 'My Collections';

  @override
  String get watchLater => 'Watch Later';

  @override
  String get watched => 'Watched';

  @override
  String get favorites => 'Favorites';

  @override
  String get customLists => 'My Lists';

  @override
  String get listsNav => 'Lists';

  @override
  String get createList => 'Create list';

  @override
  String get createListTitle => 'New list';

  @override
  String get listName => 'List name';

  @override
  String get listDescription => 'Description (optional)';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get deleteListTitle => 'Delete list';

  @override
  String deleteListMessage(Object name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteItemTitle => 'Delete item';

  @override
  String deleteItemMessage(Object name) {
    return 'Delete \"$name\" from this list?';
  }

  @override
  String get saveChangesTitle => 'Save changes';

  @override
  String get saveChangesMessage => 'Save the changes made?';

  @override
  String get emptyList => 'This list is empty';

  @override
  String itemsCount(Object count) {
    return '$count items';
  }

  @override
  String get noResults => 'No results in this category';

  @override
  String get nothingHere => 'Nothing here yet';

  @override
  String get tryOtherCategory => 'Try selecting another category';

  @override
  String get searchAndAdd =>
      'Search movies, series, and other content, organize your lists, and share your discoveries with the community.';

  @override
  String get createFirstList => 'Create your first custom list';

  @override
  String get all => 'All';

  @override
  String get movie => 'Movie';

  @override
  String get series => 'Series';

  @override
  String get anime => 'Anime';

  @override
  String get cartoon => 'Cartoon';

  @override
  String get documentary => 'Documentary';

  @override
  String get concert => 'Concert';

  @override
  String get other => 'Other';

  @override
  String get noSynopsis => 'No synopsis available';

  @override
  String get inYourLibrary => 'In your collections';

  @override
  String get actions => 'Actions';

  @override
  String get addToWatchLater => 'Watch Later';

  @override
  String get markAsWatched => 'Already watched';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get moveToWatchLater => 'Move to Watch Later';

  @override
  String get markAsWatchedAction => 'Mark as watched';

  @override
  String get removeFromLibrary => 'Remove from collections';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get addedToWatchLater => 'Added to Watch Later';

  @override
  String get markedAsWatched => 'Marked as watched';

  @override
  String get addedToLibrary => 'Added to collections';

  @override
  String get removedFromLibrary => 'Removed from collections';

  @override
  String get errorLoading => 'Error loading';

  @override
  String get error => 'Error';

  @override
  String get loggedInAs => 'Signed in with Google';

  @override
  String get memberSince => 'Member since';

  @override
  String get total => 'Total';

  @override
  String get viewed => 'Watched';

  @override
  String get logout => 'Log out';

  @override
  String get logoutTitle => 'Do you want to log out?';

  @override
  String get logoutMessage =>
      'You will need to log in again to access your account.';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get settings => 'Settings';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get age => 'Age';

  @override
  String get email => 'Email';

  @override
  String get gender => 'Gender';

  @override
  String get bio => 'Bio';

  @override
  String get photoURL => 'Profile photo URL';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get nonBinary => 'Non-binary';

  @override
  String get preferNotToSay => 'Prefer not to say';

  @override
  String get otherGender => 'Other';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get profileUpdateError => 'Error updating profile';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get portuguese => 'Portuguese';

  @override
  String get italian => 'Italian';

  @override
  String get french => 'French';

  @override
  String get russian => 'Russian';

  @override
  String get korean => 'Korean';

  @override
  String get japanese => 'Japanese';

  @override
  String get chinese => 'Chinese';

  @override
  String get share => 'Share';

  @override
  String shareMovie(Object title, Object type) {
    return 'Check out this $type: $title';
  }

  @override
  String shareMovieDescription(Object overview) {
    return '$overview';
  }

  @override
  String shareList(Object name) {
    return 'List: $name';
  }

  @override
  String shareListDescription(Object count, Object description) {
    return '$description\n$count items on MovieMemory';
  }

  @override
  String shareListItems(Object name) {
    return 'Content in $name:';
  }

  @override
  String get addToList => 'Add to list';

  @override
  String get addToListTitle => 'Add to list';

  @override
  String get selectList => 'Select a list';

  @override
  String get addedToList => 'Added to list';

  @override
  String get editList => 'Edit list';

  @override
  String get editListTitle => 'Edit list';

  @override
  String get newFieldRequired => 'This field is required';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get ageRange => 'Must be between 0 and 150';

  @override
  String get saveConfirmation => 'Save changes?';

  @override
  String get typeMovie => 'movie';

  @override
  String get typeSeries => 'series';

  @override
  String get markAsWatchedShort => 'Watched';

  @override
  String get favoriteShort => 'Favorite';

  @override
  String get signOut => 'Sign out';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get noItemsInList => 'No items in this list';

  @override
  String get listInfo => 'List info';

  @override
  String get searchResults => 'Search results';

  @override
  String get user => 'User';

  @override
  String get trending => 'Trending Today';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get popularMovies => 'Popular Movies';

  @override
  String get popularTv => 'Popular TV Shows';

  @override
  String get topRated => 'Top Rated';

  @override
  String get loginSubtitle =>
      'Platform to discover, organize, and enjoy multimedia content.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get or => 'or';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign In';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get googleSignInError => 'Error signing in with Google';

  @override
  String get fillAllFields => 'Please fill all fields';

  @override
  String get verifyEmailFirst => 'You must verify your email before signing in';

  @override
  String get wrongCredentials => 'Wrong credentials';

  @override
  String get loginError => 'Error signing in';

  @override
  String get enterEmailFirst => 'Enter your email first';

  @override
  String get recoveryEmailSent => 'Recovery email sent';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle =>
      'Manage your collections, create custom lists, and share.';

  @override
  String get nameLabel => 'First name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get logIn => 'Log in';

  @override
  String get createAccount => 'Create account';

  @override
  String get registrationSuccess => 'Registration successful';

  @override
  String get confirmationSent =>
      'Confirmation link sent to your email. Check your inbox or spam folder.';

  @override
  String get accept => 'ACCEPT';

  @override
  String get completeAllFields => 'Complete all fields';

  @override
  String get mustBe18 => 'You must be at least 18 years old to register';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String minPasswordLength(Object length) {
    return 'Password must be at least $length characters';
  }

  @override
  String get emailAlreadyInUse => 'Email already in use';

  @override
  String get checkYourEmail => 'Check your email!';

  @override
  String get verificationSentTo => 'We sent a verification link to:';

  @override
  String get clickToActivate =>
      'Click the link in the email to activate your account and sign in.';

  @override
  String get noEmailCheckSpam =>
      'Can\'t see the email? Check your spam or junk folder.';

  @override
  String get goToLogin => 'Go to Login';

  @override
  String get yourPreferences => 'Your preferences';

  @override
  String get selectFavoriteGenres =>
      'Select your favorite genres to get personalized recommendations';

  @override
  String get favoriteGenres => 'Favorite genres';

  @override
  String get contentTypes => 'Content types';

  @override
  String get start => 'Start';

  @override
  String get skip => 'Skip';

  @override
  String get synopsis => 'Synopsis';

  @override
  String get movedToWatchLater => 'Moved to Watch Later';

  @override
  String get minutesLabel => 'min';

  @override
  String get searchHintEmpty => 'Type something to search';

  @override
  String get noResultsSearch => 'No results';

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
      'MovieMemory is your personal platform to discover, organize, and enjoy multimedia content. Manage your collections, create custom lists, and share with the community.';

  @override
  String get developer => 'Developer';

  @override
  String get credits =>
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';

  @override
  String get releaseDate => 'Release date';

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
  String get soundSettings => 'Sound settings';

  @override
  String get openAppSound => 'App startup sound';

  @override
  String get clickSound => 'Click sound';

  @override
  String get addSound => 'Add sound';

  @override
  String get confirmSound => 'Confirm sound';

  @override
  String get removeSound => 'Remove sound';

  @override
  String get errorSound => 'Error sound';

  @override
  String get freesoundCredit => 'Sounds under Free Commons license';

  @override
  String get notificationSound => 'Notification sound';

  @override
  String get supportEmail => 'Support email';

  @override
  String get silentMode => 'Silent mode';

  @override
  String get silentModeDesc => 'Disables all application sounds';

  @override
  String get playbackLanguage => 'Playback language';

  @override
  String get defaultAudioLanguage => 'Default audio language';

  @override
  String get defaultSubtitleLanguage => 'Default subtitle language';

  @override
  String get appLanguage => 'App language';

  @override
  String get systemLanguage => 'System language';

  @override
  String get originalLanguage => 'Original language';

  @override
  String get subtitlesDisabled => 'Disabled';

  @override
  String get exitPlayerTitle => 'Do you want to exit the player?';

  @override
  String get exitPlayerMessage =>
      'If you exit now, current playback will be stopped.';

  @override
  String get continueWatching => 'Continue watching';

  @override
  String get exit => 'Exit';

  @override
  String get follow => 'Follow';

  @override
  String get following => 'Following';

  @override
  String get contentPreferencesNotif => 'Content preferences for notifications';
}
