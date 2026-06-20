// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'MovieMemory';

  @override
  String get discover => 'Открыть';

  @override
  String get search => 'Поиск';

  @override
  String get searchHint => 'Поиск фильмов, сериалов...';

  @override
  String get library => 'Коллекции';

  @override
  String get profile => 'Профиль';

  @override
  String get myLibrary => 'Мои коллекции';

  @override
  String get watchLater => 'Посмотреть позже';

  @override
  String get watched => 'Просмотрено';

  @override
  String get favorites => 'Избранное';

  @override
  String get customLists => 'Мои списки';

  @override
  String get listsNav => 'Списки';

  @override
  String get createList => 'Создать список';

  @override
  String get createListTitle => 'Новый список';

  @override
  String get listName => 'Название списка';

  @override
  String get listDescription => 'Описание (необязательно)';

  @override
  String get cancel => 'Отмена';

  @override
  String get create => 'Создать';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get close => 'Закрыть';

  @override
  String get deleteListTitle => 'Удалить список';

  @override
  String deleteListMessage(Object name) {
    return 'Удалить \"$name\"?';
  }

  @override
  String get deleteItemTitle => 'Удалить элемент';

  @override
  String deleteItemMessage(Object name) {
    return 'Удалить \"$name\" из этого списка?';
  }

  @override
  String get saveChangesTitle => 'Сохранить изменения';

  @override
  String get saveChangesMessage => 'Сохранить внесенные изменения?';

  @override
  String get emptyList => 'Этот список пуст';

  @override
  String itemsCount(Object count) {
    return '$count элементов';
  }

  @override
  String get noResults => 'Нет результатов в этой категории';

  @override
  String get nothingHere => 'Здесь пока ничего нет';

  @override
  String get tryOtherCategory => 'Попробуйте выбрать другую категорию';

  @override
  String get searchAndAdd =>
      'Ищите фильмы, сериалы и другой контент, организуйте свои списки и делитесь своими открытиями с сообществом.';

  @override
  String get createFirstList => 'Создайте свой первый пользовательский список';

  @override
  String get all => 'Все';

  @override
  String get movie => 'Фильм';

  @override
  String get series => 'Сериал';

  @override
  String get anime => 'Аниме';

  @override
  String get cartoon => 'Мультфильм';

  @override
  String get documentary => 'Документальный';

  @override
  String get concert => 'Концерт';

  @override
  String get other => 'Другое';

  @override
  String get noSynopsis => 'Синопсис недоступен';

  @override
  String get inYourLibrary => 'В ваших коллекциях';

  @override
  String get actions => 'Действия';

  @override
  String get addToWatchLater => 'Посмотреть позже';

  @override
  String get markAsWatched => 'Уже просмотрено';

  @override
  String get addToFavorites => 'Добавить в избранное';

  @override
  String get removeFromFavorites => 'Убрать из избранного';

  @override
  String get moveToWatchLater => 'Переместить в \"Посмотреть позже\"';

  @override
  String get markAsWatchedAction => 'Отметить как просмотренное';

  @override
  String get removeFromLibrary => 'Удалить из коллекций';

  @override
  String get addedToFavorites => 'Добавлено в избранное';

  @override
  String get addedToWatchLater => 'Добавлено в \"Посмотреть позже\"';

  @override
  String get markedAsWatched => 'Отмечено как просмотренное';

  @override
  String get addedToLibrary => 'Добавлено в коллекции';

  @override
  String get removedFromLibrary => 'Удалено из коллекций';

  @override
  String get errorLoading => 'Ошибка загрузки';

  @override
  String get error => 'Ошибка';

  @override
  String get loggedInAs => 'Вход через Google';

  @override
  String get memberSince => 'Участник с';

  @override
  String get total => 'Всего';

  @override
  String get viewed => 'Просмотрено';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutTitle => 'Вы хотите выйти?';

  @override
  String get logoutMessage =>
      'Вам придется снова войти в систему, чтобы получить доступ к своей учетной записи.';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get firstName => 'Имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String get age => 'Возраст';

  @override
  String get email => 'Email';

  @override
  String get gender => 'Пол';

  @override
  String get bio => 'Биография';

  @override
  String get photoURL => 'URL фото профиля';

  @override
  String get male => 'Мужской';

  @override
  String get female => 'Женский';

  @override
  String get nonBinary => 'Небинарный';

  @override
  String get preferNotToSay => 'Предпочитаю не указывать';

  @override
  String get otherGender => 'Другое';

  @override
  String get profileUpdated => 'Профиль успешно обновлен';

  @override
  String get profileUpdateError => 'Ошибка обновления профиля';

  @override
  String get language => 'Язык';

  @override
  String get spanish => 'Испанский';

  @override
  String get english => 'Английский';

  @override
  String get portuguese => 'Португальский';

  @override
  String get italian => 'Итальянский';

  @override
  String get french => 'Французский';

  @override
  String get russian => 'Русский';

  @override
  String get korean => 'Корейский';

  @override
  String get japanese => 'Японский';

  @override
  String get chinese => 'Китайский';

  @override
  String get share => 'Поделиться';

  @override
  String shareMovie(Object title, Object type) {
    return 'Посмотрите этот $type: $title';
  }

  @override
  String shareMovieDescription(Object overview) {
    return '$overview';
  }

  @override
  String shareList(Object name) {
    return 'Список: $name';
  }

  @override
  String shareListDescription(Object count, Object description) {
    return '$description\n$count элементов в MovieMemory';
  }

  @override
  String shareListItems(Object name) {
    return 'Контент в $name:';
  }

  @override
  String get addToList => 'Добавить в список';

  @override
  String get addToListTitle => 'Добавить в список';

  @override
  String get selectList => 'Выберите список';

  @override
  String get addedToList => 'Добавлено в список';

  @override
  String get editList => 'Редактировать список';

  @override
  String get editListTitle => 'Редактировать список';

  @override
  String get newFieldRequired => 'Это поле обязательно';

  @override
  String get fieldRequired => 'Это поле обязательно';

  @override
  String get invalidEmail => 'Неверный email';

  @override
  String get ageRange => 'Должно быть от 0 до 150';

  @override
  String get saveConfirmation => 'Сохранить изменения?';

  @override
  String get typeMovie => 'фильм';

  @override
  String get typeSeries => 'сериал';

  @override
  String get markAsWatchedShort => 'Просмотрено';

  @override
  String get favoriteShort => 'Избранное';

  @override
  String get signOut => 'Выйти';

  @override
  String get loading => 'Загрузка...';

  @override
  String get retry => 'Повторить';

  @override
  String get noItemsInList => 'Нет элементов в этом списке';

  @override
  String get listInfo => 'Информация о списке';

  @override
  String get searchResults => 'Результаты поиска';

  @override
  String get user => 'Пользователь';

  @override
  String get trending => 'В тренде сегодня';

  @override
  String get nowPlaying => 'Сейчас в кино';

  @override
  String get popularMovies => 'Популярные фильмы';

  @override
  String get popularTv => 'Популярные сериалы';

  @override
  String get topRated => 'С высоким рейтингом';

  @override
  String get loginSubtitle =>
      'Платформа для поиска, организации и просмотра мультимедийного контента.';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get or => 'или';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get signIn => 'Войти';

  @override
  String get noAccount => 'Нет аккаунта?';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get googleSignInError => 'Ошибка входа через Google';

  @override
  String get fillAllFields => 'Заполните все поля';

  @override
  String get verifyEmailFirst => 'Сначала подтвердите email';

  @override
  String get wrongCredentials => 'Неверные данные';

  @override
  String get loginError => 'Ошибка входа';

  @override
  String get enterEmailFirst => 'Сначала введите email';

  @override
  String get recoveryEmailSent => 'Письмо восстановления отправлено';

  @override
  String get registerTitle => 'Создать аккаунт';

  @override
  String get registerSubtitle =>
      'Управляйте своими коллекциями, создавайте личные списки и делитесь ими.';

  @override
  String get nameLabel => 'Имя';

  @override
  String get lastNameLabel => 'Фамилия';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get logIn => 'Войти';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get registrationSuccess => 'Регистрация успешна';

  @override
  String get confirmationSent =>
      'Ссылка для подтверждения отправлена на вашу почту. Проверьте входящие или папку спам.';

  @override
  String get accept => 'ПРИНЯТЬ';

  @override
  String get completeAllFields => 'Заполните все поля';

  @override
  String get mustBe18 => 'Вам должно быть не менее 18 лет';

  @override
  String get passwordsDontMatch => 'Пароли не совпадают';

  @override
  String minPasswordLength(Object length) {
    return 'Пароль должен содержать не менее $length символов';
  }

  @override
  String get emailAlreadyInUse => 'Email уже используется';

  @override
  String get checkYourEmail => 'Проверьте почту!';

  @override
  String get verificationSentTo => 'Мы отправили ссылку для подтверждения на:';

  @override
  String get clickToActivate =>
      'Нажмите на ссылку в письме, чтобы активировать аккаунт и войти.';

  @override
  String get noEmailCheckSpam =>
      'Не видите письмо? Проверьте папку спам или нежелательные письма.';

  @override
  String get goToLogin => 'Перейти к входу';

  @override
  String get yourPreferences => 'Ваши предпочтения';

  @override
  String get selectFavoriteGenres =>
      'Выберите любимые жанры для получения персонализированных рекомендаций';

  @override
  String get favoriteGenres => 'Любимые жанры';

  @override
  String get contentTypes => 'Типы контента';

  @override
  String get start => 'Начать';

  @override
  String get skip => 'Пропустить';

  @override
  String get synopsis => 'Синопсис';

  @override
  String get movedToWatchLater => 'Перемещено в «Посмотреть позже»';

  @override
  String get minutesLabel => 'мин';

  @override
  String get searchHintEmpty => 'Введите что-нибудь для поиска';

  @override
  String get noResultsSearch => 'Нет результатов';

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
      'MovieMemory — это ваша персональная платформа для поиска, организации и просмотра мультимедийного контента. Управляйте своими коллекциями, создавайте личные списки и делитесь ими с сообществом.';

  @override
  String get developer => 'Developer';

  @override
  String get credits =>
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';

  @override
  String get releaseDate => 'Дата выпуска';

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
  String get soundSettings => 'Настройки звука';

  @override
  String get openAppSound => 'Звук запуска приложения';

  @override
  String get clickSound => 'Звук клика';

  @override
  String get addSound => 'Звук добавления';

  @override
  String get confirmSound => 'Звук подтверждения';

  @override
  String get removeSound => 'Звук удаления';

  @override
  String get errorSound => 'Звук ошибки';

  @override
  String get freesoundCredit => 'Звуки по лицензии Free Commons';

  @override
  String get notificationSound => 'Звук уведомления';

  @override
  String get supportEmail => 'Почта поддержки';

  @override
  String get silentMode => 'Беззвучный режим';

  @override
  String get silentModeDesc => 'Отключает все звуки в приложении';

  @override
  String get playbackLanguage => 'Язык воспроизведения';

  @override
  String get defaultAudioLanguage => 'Аудиоязык по умолчанию';

  @override
  String get defaultSubtitleLanguage => 'Язык субтитров по умолчанию';

  @override
  String get appLanguage => 'Язык приложения';

  @override
  String get systemLanguage => 'Системный язык';

  @override
  String get originalLanguage => 'Оригинальный язык';

  @override
  String get subtitlesDisabled => 'Отключено';

  @override
  String get exitPlayerTitle => 'Вы хотите выйти из плеера?';

  @override
  String get exitPlayerMessage =>
      'Если вы выйдете сейчас, текущее воспроизведение будет остановлено.';

  @override
  String get continueWatching => 'Продолжить просмотр';

  @override
  String get exit => 'Выйти';

  @override
  String get follow => 'Подписаться';

  @override
  String get following => 'Вы подписаны';

  @override
  String get contentPreferencesNotif => 'Настройки контента для уведомлений';
}
