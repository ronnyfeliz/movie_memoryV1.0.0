// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'MovieMemory';

  @override
  String get discover => 'Descobrir';

  @override
  String get search => 'Pesquisar';

  @override
  String get searchHint => 'Pesquisar filmes, séries...';

  @override
  String get library => 'Coleções';

  @override
  String get profile => 'Perfil';

  @override
  String get myLibrary => 'Minhas Coleções';

  @override
  String get watchLater => 'Ver depois';

  @override
  String get watched => 'Vistos';

  @override
  String get favorites => 'Favoritos';

  @override
  String get customLists => 'Minhas Listas';

  @override
  String get listsNav => 'Listas';

  @override
  String get createList => 'Criar lista';

  @override
  String get createListTitle => 'Nova lista';

  @override
  String get listName => 'Nome da lista';

  @override
  String get listDescription => 'Descrição (opcional)';

  @override
  String get cancel => 'Cancelar';

  @override
  String get create => 'Criar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Fechar';

  @override
  String get deleteListTitle => 'Excluir lista';

  @override
  String deleteListMessage(Object name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get deleteItemTitle => 'Excluir item';

  @override
  String deleteItemMessage(Object name) {
    return 'Excluir \"$name\" desta lista?';
  }

  @override
  String get saveChangesTitle => 'Salvar alterações';

  @override
  String get saveChangesMessage => 'Salvar as alterações feitas?';

  @override
  String get emptyList => 'Esta lista está vazia';

  @override
  String itemsCount(Object count) {
    return '$count itens';
  }

  @override
  String get noResults => 'Sem resultados nesta categoria';

  @override
  String get nothingHere => 'Nada aqui ainda';

  @override
  String get tryOtherCategory => 'Tente selecionar outra categoria';

  @override
  String get searchAndAdd =>
      'Pesquise filmes, séries e outros conteúdos, organize suas listas e compartilhe suas descobertas com a comunidade.';

  @override
  String get createFirstList => 'Crie sua primeira lista personalizada';

  @override
  String get all => 'Todos';

  @override
  String get movie => 'Filme';

  @override
  String get series => 'Série';

  @override
  String get anime => 'Anime';

  @override
  String get cartoon => 'Desenho';

  @override
  String get documentary => 'Documentário';

  @override
  String get concert => 'Concerto';

  @override
  String get other => 'Outro';

  @override
  String get noSynopsis => 'Sem sinopse disponível';

  @override
  String get inYourLibrary => 'Nas suas coleções';

  @override
  String get actions => 'Ações';

  @override
  String get addToWatchLater => 'Ver depois';

  @override
  String get markAsWatched => 'Já visto';

  @override
  String get addToFavorites => 'Adicionar aos favoritos';

  @override
  String get removeFromFavorites => 'Remover dos favoritos';

  @override
  String get moveToWatchLater => 'Mover para Ver depois';

  @override
  String get markAsWatchedAction => 'Marcar como visto';

  @override
  String get removeFromLibrary => 'Remover das coleções';

  @override
  String get addedToFavorites => 'Adicionado aos favoritos';

  @override
  String get addedToWatchLater => 'Adicionado a Ver depois';

  @override
  String get markedAsWatched => 'Marcado como visto';

  @override
  String get addedToLibrary => 'Adicionado às coleções';

  @override
  String get removedFromLibrary => 'Removido das coleções';

  @override
  String get errorLoading => 'Erro ao carregar';

  @override
  String get error => 'Erro';

  @override
  String get loggedInAs => 'Conectado com Google';

  @override
  String get memberSince => 'Membro desde';

  @override
  String get total => 'Total';

  @override
  String get viewed => 'Vistos';

  @override
  String get logout => 'Sair';

  @override
  String get logoutTitle => 'Deseja encerrar a sessão?';

  @override
  String get logoutMessage =>
      'Você precisará fazer login novamente para acessar sua conta.';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get settings => 'Configurações';

  @override
  String get firstName => 'Nome';

  @override
  String get lastName => 'Sobrenome';

  @override
  String get age => 'Idade';

  @override
  String get email => 'Email';

  @override
  String get gender => 'Gênero';

  @override
  String get bio => 'Biografia';

  @override
  String get photoURL => 'URL da foto de perfil';

  @override
  String get male => 'Masculino';

  @override
  String get female => 'Feminino';

  @override
  String get nonBinary => 'Não binário';

  @override
  String get preferNotToSay => 'Prefiro não dizer';

  @override
  String get otherGender => 'Outro';

  @override
  String get profileUpdated => 'Perfil atualizado com sucesso';

  @override
  String get profileUpdateError => 'Erro ao atualizar o perfil';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Espanhol';

  @override
  String get english => 'Inglês';

  @override
  String get portuguese => 'Português';

  @override
  String get italian => 'Italiano';

  @override
  String get french => 'Francês';

  @override
  String get russian => 'Russo';

  @override
  String get korean => 'Coreano';

  @override
  String get japanese => 'Japonês';

  @override
  String get chinese => 'Chinês';

  @override
  String get share => 'Compartilhar';

  @override
  String shareMovie(Object title, Object type) {
    return 'Veja este $type: $title';
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
    return '$description\n$count itens no MovieMemory';
  }

  @override
  String shareListItems(Object name) {
    return 'Conteúdo em $name:';
  }

  @override
  String get addToList => 'Adicionar à lista';

  @override
  String get addToListTitle => 'Adicionar à lista';

  @override
  String get selectList => 'Selecione uma lista';

  @override
  String get addedToList => 'Adicionado à lista';

  @override
  String get editList => 'Editar lista';

  @override
  String get editListTitle => 'Editar lista';

  @override
  String get newFieldRequired => 'Este campo é obrigatório';

  @override
  String get fieldRequired => 'Este campo é obrigatório';

  @override
  String get invalidEmail => 'Email inválido';

  @override
  String get ageRange => 'Deve estar entre 0 e 150';

  @override
  String get saveConfirmation => 'Salvar alterações?';

  @override
  String get typeMovie => 'filme';

  @override
  String get typeSeries => 'série';

  @override
  String get markAsWatchedShort => 'Visto';

  @override
  String get favoriteShort => 'Favorito';

  @override
  String get signOut => 'Sair';

  @override
  String get loading => 'Carregando...';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get noItemsInList => 'Não há itens nesta lista';

  @override
  String get listInfo => 'Informações da lista';

  @override
  String get searchResults => 'Resultados da pesquisa';

  @override
  String get user => 'Usuário';

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
      'Plataforma para descobrir, organizar e desfrutar de conteúdo multimídia.';

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
      'Gerencie suas coleções, crie listas personalizadas e compartilhe.';

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
      'MovieMemory é sua plataforma pessoal para descobrir, organizar e desfrutar de conteúdo multimídia. Gerencie suas coleções, crie listas personalizadas e compartilhe com a comunidade.';

  @override
  String get developer => 'Developer';

  @override
  String get credits =>
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';

  @override
  String get releaseDate => 'Data de lançamento';

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
  String get soundSettings => 'Configurações de som';

  @override
  String get openAppSound => 'Som de inicialização';

  @override
  String get clickSound => 'Som de clique';

  @override
  String get addSound => 'Som de adicionar';

  @override
  String get confirmSound => 'Som de confirmação';

  @override
  String get removeSound => 'Som de remoção';

  @override
  String get errorSound => 'Som de erro';

  @override
  String get freesoundCredit => 'Sons sob licença Free Commons';

  @override
  String get notificationSound => 'Som de notificação';

  @override
  String get supportEmail => 'Email de suporte';

  @override
  String get silentMode => 'Modo silencioso';

  @override
  String get silentModeDesc => 'Desativa todos os sons do aplicativo';

  @override
  String get playbackLanguage => 'Idioma de reprodução';

  @override
  String get defaultAudioLanguage => 'Idioma de áudio padrão';

  @override
  String get defaultSubtitleLanguage => 'Idioma de legenda padrão';

  @override
  String get appLanguage => 'Idioma do aplicativo';

  @override
  String get systemLanguage => 'Idioma do sistema';

  @override
  String get originalLanguage => 'Idioma original';

  @override
  String get subtitlesDisabled => 'Desativado';

  @override
  String get exitPlayerTitle => 'Deseja sair do reprodutor?';

  @override
  String get exitPlayerMessage =>
      'Se você sair agora, a reprodução atual será interrompida.';

  @override
  String get continueWatching => 'Continuar assistindo';

  @override
  String get exit => 'Sair';

  @override
  String get follow => 'Seguir';

  @override
  String get following => 'Seguindo';

  @override
  String get contentPreferencesNotif =>
      'Preferências de conteúdo para notificações';
}
