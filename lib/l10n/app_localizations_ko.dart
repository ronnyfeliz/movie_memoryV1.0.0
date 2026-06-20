// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'MovieMemory';

  @override
  String get discover => '발견';

  @override
  String get search => '검색';

  @override
  String get searchHint => '영화, 시리즈 검색...';

  @override
  String get library => '컬렉션';

  @override
  String get profile => '프로필';

  @override
  String get myLibrary => '내 컬렉션';

  @override
  String get watchLater => '나중에 볼 것';

  @override
  String get watched => '본 것';

  @override
  String get favorites => '즐겨찾기';

  @override
  String get customLists => '내 목록';

  @override
  String get listsNav => '목록';

  @override
  String get createList => '목록 만들기';

  @override
  String get createListTitle => '새 목록';

  @override
  String get listName => '목록 이름';

  @override
  String get listDescription => '설명 (선택사항)';

  @override
  String get cancel => '취소';

  @override
  String get create => '만들기';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get edit => '편집';

  @override
  String get confirm => '확인';

  @override
  String get close => '닫기';

  @override
  String get deleteListTitle => '목록 삭제';

  @override
  String deleteListMessage(Object name) {
    return '\"$name\"을(를) 삭제하시겠습니까?';
  }

  @override
  String get deleteItemTitle => '항목 삭제';

  @override
  String deleteItemMessage(Object name) {
    return '이 목록에서 \"$name\"을(를) 삭제하시겠습니까?';
  }

  @override
  String get saveChangesTitle => '변경사항 저장';

  @override
  String get saveChangesMessage => '변경사항을 저장하시겠습니까?';

  @override
  String get emptyList => '이 목록이 비어 있습니다';

  @override
  String itemsCount(Object count) {
    return '$count개 항목';
  }

  @override
  String get noResults => '이 카테고리에 결과가 없습니다';

  @override
  String get nothingHere => '아직 아무것도 없습니다';

  @override
  String get tryOtherCategory => '다른 카테고리를 선택해보세요';

  @override
  String get searchAndAdd =>
      '영화, 시리즈 등 콘텐츠를 검색하고, 나만의 목록을 정리하고, 발견한 내용을 커뮤니티와 공유해보세요.';

  @override
  String get createFirstList => '첫 번째 맞춤 목록을 만드세요';

  @override
  String get all => '모두';

  @override
  String get movie => '영화';

  @override
  String get series => '시리즈';

  @override
  String get anime => '애니메이션';

  @override
  String get cartoon => '만화';

  @override
  String get documentary => '다큐멘터리';

  @override
  String get concert => '콘서트';

  @override
  String get other => '기타';

  @override
  String get noSynopsis => '시놉시스를 사용할 수 없습니다';

  @override
  String get inYourLibrary => '내 컬렉션에서';

  @override
  String get actions => '작업';

  @override
  String get addToWatchLater => '나중에 볼 것';

  @override
  String get markAsWatched => '이미 봄';

  @override
  String get addToFavorites => '즐겨찾기에 추가';

  @override
  String get removeFromFavorites => '즐겨찾기에서 제거';

  @override
  String get moveToWatchLater => '\"나중에 볼 것\"으로 이동';

  @override
  String get markAsWatchedAction => '본 것으로 표시';

  @override
  String get removeFromLibrary => '컬렉션에서 제거';

  @override
  String get addedToFavorites => '즐겨찾기에 추가됨';

  @override
  String get addedToWatchLater => '\"나중에 볼 것\"에 추가됨';

  @override
  String get markedAsWatched => '본 것으로 표시됨';

  @override
  String get addedToLibrary => '컬렉션에 추가됨';

  @override
  String get removedFromLibrary => '컬렉션에서 제거됨';

  @override
  String get errorLoading => '로딩 오류';

  @override
  String get error => '오류';

  @override
  String get loggedInAs => 'Google로 로그인';

  @override
  String get memberSince => '가입일';

  @override
  String get total => '전체';

  @override
  String get viewed => '본 것';

  @override
  String get logout => '로그아웃';

  @override
  String get logoutTitle => '로그아웃하시겠습니까?';

  @override
  String get logoutMessage => '계정에 액세스하려면 다시 로그인해야 합니다.';

  @override
  String get editProfile => '프로필 편집';

  @override
  String get settings => '설정';

  @override
  String get firstName => '이름';

  @override
  String get lastName => '성';

  @override
  String get age => '나이';

  @override
  String get email => '이메일';

  @override
  String get gender => '성별';

  @override
  String get bio => '소개';

  @override
  String get photoURL => '프로필 사진 URL';

  @override
  String get male => '남성';

  @override
  String get female => '여성';

  @override
  String get nonBinary => '논바이너리';

  @override
  String get preferNotToSay => '말하고 싶지 않음';

  @override
  String get otherGender => '기타';

  @override
  String get profileUpdated => '프로필이 성공적으로 업데이트되었습니다';

  @override
  String get profileUpdateError => '프로필 업데이트 중 오류 발생';

  @override
  String get language => '언어';

  @override
  String get spanish => '스페인어';

  @override
  String get english => '영어';

  @override
  String get portuguese => '포르투갈어';

  @override
  String get italian => '이탈리아어';

  @override
  String get french => '프랑스어';

  @override
  String get russian => '러시아어';

  @override
  String get korean => '한국어';

  @override
  String get japanese => '일본어';

  @override
  String get chinese => '중국어';

  @override
  String get share => '공유';

  @override
  String shareMovie(Object title, Object type) {
    return '이 $type을(를) 확인하세요: $title';
  }

  @override
  String shareMovieDescription(Object overview) {
    return '$overview';
  }

  @override
  String shareList(Object name) {
    return '목록: $name';
  }

  @override
  String shareListDescription(Object count, Object description) {
    return '$description\nMovieMemory에서 $count개 항목';
  }

  @override
  String shareListItems(Object name) {
    return '$name의 콘텐츠:';
  }

  @override
  String get addToList => '목록에 추가';

  @override
  String get addToListTitle => '목록에 추가';

  @override
  String get selectList => '목록 선택';

  @override
  String get addedToList => '목록에 추가됨';

  @override
  String get editList => '목록 편집';

  @override
  String get editListTitle => '목록 편집';

  @override
  String get newFieldRequired => '이 필드는 필수입니다';

  @override
  String get fieldRequired => '이 필드는 필수입니다';

  @override
  String get invalidEmail => '유효하지 않은 이메일';

  @override
  String get ageRange => '0에서 150 사이여야 합니다';

  @override
  String get saveConfirmation => '변경사항을 저장하시겠습니까?';

  @override
  String get typeMovie => '영화';

  @override
  String get typeSeries => '시리즈';

  @override
  String get markAsWatchedShort => '봄';

  @override
  String get favoriteShort => '즐겨찾기';

  @override
  String get signOut => '로그아웃';

  @override
  String get loading => '로딩 중...';

  @override
  String get retry => '재시도';

  @override
  String get noItemsInList => '이 목록에 항목이 없습니다';

  @override
  String get listInfo => '목록 정보';

  @override
  String get searchResults => '검색 결과';

  @override
  String get user => '사용자';

  @override
  String get trending => '오늘의 트렌드';

  @override
  String get nowPlaying => '현재 상영중';

  @override
  String get popularMovies => '인기 영화';

  @override
  String get popularTv => '인기 TV 프로그램';

  @override
  String get topRated => '최고 평점';

  @override
  String get loginSubtitle => '멀티미디어 콘텐츠를 발견하고 정리하며 즐길 수 있는 플랫폼입니다.';

  @override
  String get continueWithGoogle => 'Google로 계속하기';

  @override
  String get or => '또는';

  @override
  String get emailLabel => '이메일';

  @override
  String get passwordLabel => '비밀번호';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get signIn => '로그인';

  @override
  String get noAccount => '계정이 없으신가요?';

  @override
  String get signUp => '가입하기';

  @override
  String get googleSignInError => 'Google 로그인 오류';

  @override
  String get fillAllFields => '모든 필드를 채워주세요';

  @override
  String get verifyEmailFirst => '로그인 전에 이메일 인증을 완료해주세요';

  @override
  String get wrongCredentials => '잘못된 인증 정보';

  @override
  String get loginError => '로그인 오류';

  @override
  String get enterEmailFirst => '먼저 이메일을 입력하세요';

  @override
  String get recoveryEmailSent => '복구 이메일 전송됨';

  @override
  String get registerTitle => '계정 만들기';

  @override
  String get registerSubtitle => '컬렉션을 관리하고, 맞춤 목록을 만들고, 공유해보세요.';

  @override
  String get nameLabel => '이름';

  @override
  String get lastNameLabel => '성';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get alreadyHaveAccount => '이미 계정이 있으신가요?';

  @override
  String get logIn => '로그인';

  @override
  String get createAccount => '계정 만들기';

  @override
  String get registrationSuccess => '회원가입 성공';

  @override
  String get confirmationSent => '확인 링크가 이메일로 전송되었습니다. 받은 편지함 또는 스팸 폴더를 확인하세요.';

  @override
  String get accept => '확인';

  @override
  String get completeAllFields => '모든 필드를 입력하세요';

  @override
  String get mustBe18 => '만 18세 이상이어야 합니다';

  @override
  String get passwordsDontMatch => '비밀번호가 일치하지 않습니다';

  @override
  String minPasswordLength(Object length) {
    return '비밀번호는 최소 $length자 이상이어야 합니다';
  }

  @override
  String get emailAlreadyInUse => '이미 사용 중인 이메일입니다';

  @override
  String get checkYourEmail => '이메일을 확인하세요!';

  @override
  String get verificationSentTo => '인증 링크를 다음 주소로 보냈습니다:';

  @override
  String get clickToActivate => '이메일의 링크를 클릭하여 계정을 활성화하고 로그인하세요.';

  @override
  String get noEmailCheckSpam => '이메일이 안 보이나요? 스팸 또는 정크 폴더를 확인하세요.';

  @override
  String get goToLogin => '로그인으로 이동';

  @override
  String get yourPreferences => '취향 설정';

  @override
  String get selectFavoriteGenres => '좋아하는 장르를 선택하여 개인 맞춤 추천을 받아보세요';

  @override
  String get favoriteGenres => '선호 장르';

  @override
  String get contentTypes => '콘텐츠 유형';

  @override
  String get start => '시작';

  @override
  String get skip => '건너뛰기';

  @override
  String get synopsis => '시놉시스';

  @override
  String get movedToWatchLater => '나중에 보기로 이동됨';

  @override
  String get minutesLabel => '분';

  @override
  String get searchHintEmpty => '검색어를 입력하세요';

  @override
  String get noResultsSearch => '검색 결과 없음';

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
      'MovieMemory는 멀티미디어 콘텐츠를 발견하고 정리하며 즐길 수 있는 개인 플랫폼입니다. 컬렉션을 관리하고 맞춤 목록을 생성하며 커뮤니티와 공유할 수 있습니다.';

  @override
  String get developer => 'Developer';

  @override
  String get credits =>
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';

  @override
  String get releaseDate => '출시일';

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
  String get soundSettings => '소리 설정';

  @override
  String get openAppSound => '앱 시작 소리';

  @override
  String get clickSound => '클릭 소리';

  @override
  String get addSound => '추가 소리';

  @override
  String get confirmSound => '확인 소리';

  @override
  String get removeSound => '제거 소리';

  @override
  String get errorSound => '오류 소리';

  @override
  String get freesoundCredit => 'Free Commons 라이선스 사운드';

  @override
  String get notificationSound => '알림 소리';

  @override
  String get supportEmail => '지원 이메일';

  @override
  String get silentMode => '무음 모드';

  @override
  String get silentModeDesc => '앱의 모든 소리를 비활성화합니다';

  @override
  String get playbackLanguage => '재생 언어';

  @override
  String get defaultAudioLanguage => '기본 오디오 언어';

  @override
  String get defaultSubtitleLanguage => '기본 자막 언어';

  @override
  String get appLanguage => '앱 언어';

  @override
  String get systemLanguage => '시스템 언어';

  @override
  String get originalLanguage => '원래 언어';

  @override
  String get subtitlesDisabled => '비활성화됨';

  @override
  String get exitPlayerTitle => '플레이어를 종료하시겠습니까?';

  @override
  String get exitPlayerMessage => '지금 종료하면 현재 재생이 중지됩니다.';

  @override
  String get continueWatching => '계속 시청하기';

  @override
  String get exit => '종료';

  @override
  String get follow => '팔로우';

  @override
  String get following => '팔로잉';

  @override
  String get contentPreferencesNotif => '알림을 위한 콘텐츠 환경설정';
}
