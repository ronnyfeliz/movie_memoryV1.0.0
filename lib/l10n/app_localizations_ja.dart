// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'MovieMemory';

  @override
  String get discover => '発見';

  @override
  String get search => '検索';

  @override
  String get searchHint => '映画、シリーズを検索...';

  @override
  String get library => 'コレクション';

  @override
  String get profile => 'プロフィール';

  @override
  String get myLibrary => 'マイコレクション';

  @override
  String get watchLater => '後で見る';

  @override
  String get watched => '見た';

  @override
  String get favorites => 'お気に入り';

  @override
  String get customLists => 'マイリスト';

  @override
  String get listsNav => 'リスト';

  @override
  String get createList => 'リストを作成';

  @override
  String get createListTitle => '新しいリスト';

  @override
  String get listName => 'リスト名';

  @override
  String get listDescription => '説明（オプション）';

  @override
  String get cancel => 'キャンセル';

  @override
  String get create => '作成';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get confirm => '確認';

  @override
  String get close => '閉じる';

  @override
  String get deleteListTitle => 'リストを削除';

  @override
  String deleteListMessage(Object name) {
    return '\"$name\"を削除しますか？';
  }

  @override
  String get deleteItemTitle => '項目を削除';

  @override
  String deleteItemMessage(Object name) {
    return 'このリストから\"$name\"を削除しますか？';
  }

  @override
  String get saveChangesTitle => '変更を保存';

  @override
  String get saveChangesMessage => '行った変更を保存しますか？';

  @override
  String get emptyList => 'このリストは空です';

  @override
  String itemsCount(Object count) {
    return '$count項目';
  }

  @override
  String get noResults => 'このカテゴリに結果はありません';

  @override
  String get nothingHere => 'まだ何もありません';

  @override
  String get tryOtherCategory => '別のカテゴリを選択してみてください';

  @override
  String get searchAndAdd =>
      '映画、シリーズなどのコンテンツを検索し、マイリストを整理し、発見した内容をコミュニティと共有しましょう。';

  @override
  String get createFirstList => '最初のカスタムリストを作成';

  @override
  String get all => 'すべて';

  @override
  String get movie => '映画';

  @override
  String get series => 'シリーズ';

  @override
  String get anime => 'アニメ';

  @override
  String get cartoon => 'アニメーション';

  @override
  String get documentary => 'ドキュメンタリー';

  @override
  String get concert => 'コンサート';

  @override
  String get other => 'その他';

  @override
  String get noSynopsis => '概要がありません';

  @override
  String get inYourLibrary => 'コレクション内';

  @override
  String get actions => 'アクション';

  @override
  String get addToWatchLater => '後で見る';

  @override
  String get markAsWatched => 'もう見た';

  @override
  String get addToFavorites => 'お気に入りに追加';

  @override
  String get removeFromFavorites => 'お気に入りから削除';

  @override
  String get moveToWatchLater => '後で見るに移動';

  @override
  String get markAsWatchedAction => '見たとしてマーク';

  @override
  String get removeFromLibrary => 'コレクションから削除';

  @override
  String get addedToFavorites => 'お気に入りに追加しました';

  @override
  String get addedToWatchLater => '後で見るに追加しました';

  @override
  String get markedAsWatched => '見たとしてマークしました';

  @override
  String get addedToLibrary => 'コレクションに追加しました';

  @override
  String get removedFromLibrary => 'コレクションから削除しました';

  @override
  String get errorLoading => '読み込みエラー';

  @override
  String get error => 'エラー';

  @override
  String get loggedInAs => 'Googleでログイン中';

  @override
  String get memberSince => 'メンバー since';

  @override
  String get total => '合計';

  @override
  String get viewed => '見た';

  @override
  String get logout => 'ログアウト';

  @override
  String get logoutTitle => 'ログアウトしますか？';

  @override
  String get logoutMessage => 'アカウントにアクセスするには、再度ログインする必要があります。';

  @override
  String get editProfile => 'プロフィールを編集';

  @override
  String get settings => '設定';

  @override
  String get firstName => '名';

  @override
  String get lastName => '姓';

  @override
  String get age => '年齢';

  @override
  String get email => 'メール';

  @override
  String get gender => '性別';

  @override
  String get bio => '自己紹介';

  @override
  String get photoURL => 'プロフィール写真URL';

  @override
  String get male => '男性';

  @override
  String get female => '女性';

  @override
  String get nonBinary => 'ノンバイナリー';

  @override
  String get preferNotToSay => '回答しない';

  @override
  String get otherGender => 'その他';

  @override
  String get profileUpdated => 'プロフィールを更新しました';

  @override
  String get profileUpdateError => 'プロフィールの更新中にエラーが発生しました';

  @override
  String get language => '言語';

  @override
  String get spanish => 'スペイン語';

  @override
  String get english => '英語';

  @override
  String get portuguese => 'ポルトガル語';

  @override
  String get italian => 'イタリア語';

  @override
  String get french => 'フランス語';

  @override
  String get russian => 'ロシア語';

  @override
  String get korean => '韓国語';

  @override
  String get japanese => '日本語';

  @override
  String get chinese => '中国語';

  @override
  String get share => '共有';

  @override
  String shareMovie(Object title, Object type) {
    return 'この$typeをチェック: $title';
  }

  @override
  String shareMovieDescription(Object overview) {
    return '$overview';
  }

  @override
  String shareList(Object name) {
    return 'リスト: $name';
  }

  @override
  String shareListDescription(Object count, Object description) {
    return '$description\nMovieMemoryの$count項目';
  }

  @override
  String shareListItems(Object name) {
    return '$nameのコンテンツ:';
  }

  @override
  String get addToList => 'リストに追加';

  @override
  String get addToListTitle => 'リストに追加';

  @override
  String get selectList => 'リストを選択';

  @override
  String get addedToList => 'リストに追加しました';

  @override
  String get editList => 'リストを編集';

  @override
  String get editListTitle => 'リストを編集';

  @override
  String get newFieldRequired => 'このフィールドは必須です';

  @override
  String get fieldRequired => 'このフィールドは必須です';

  @override
  String get invalidEmail => '無効なメールアドレス';

  @override
  String get ageRange => '0から150の間でなければなりません';

  @override
  String get saveConfirmation => '変更を保存しますか？';

  @override
  String get typeMovie => '映画';

  @override
  String get typeSeries => 'シリーズ';

  @override
  String get markAsWatchedShort => '見た';

  @override
  String get favoriteShort => 'お気に入り';

  @override
  String get signOut => 'ログアウト';

  @override
  String get loading => '読み込み中...';

  @override
  String get retry => '再試行';

  @override
  String get noItemsInList => 'このリストに項目はありません';

  @override
  String get listInfo => 'リスト情報';

  @override
  String get searchResults => '検索結果';

  @override
  String get user => 'ユーザー';

  @override
  String get trending => '今日のトレンド';

  @override
  String get nowPlaying => '現在上映中';

  @override
  String get popularMovies => '人気の映画';

  @override
  String get popularTv => '人気のテレビ番組';

  @override
  String get topRated => '高評価';

  @override
  String get loginSubtitle => 'マルチメディアコンテンツを発見・整理し、楽しむためのプラットフォームです。';

  @override
  String get continueWithGoogle => 'Googleで続ける';

  @override
  String get or => 'または';

  @override
  String get emailLabel => 'メールアドレス';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get signIn => 'ログイン';

  @override
  String get noAccount => 'アカウントをお持ちでない方';

  @override
  String get signUp => '登録する';

  @override
  String get googleSignInError => 'Googleログインエラー';

  @override
  String get fillAllFields => 'すべての項目を入力してください';

  @override
  String get verifyEmailFirst => 'ログイン前にメール認証を行ってください';

  @override
  String get wrongCredentials => '認証情報が間違っています';

  @override
  String get loginError => 'ログインエラー';

  @override
  String get enterEmailFirst => '最初にメールアドレスを入力してください';

  @override
  String get recoveryEmailSent => '復旧メールを送信しました';

  @override
  String get registerTitle => 'アカウント作成';

  @override
  String get registerSubtitle => 'コレクションを管理し、カスタムリストを作成して共有しましょう。';

  @override
  String get nameLabel => '名前';

  @override
  String get lastNameLabel => '姓';

  @override
  String get confirmPassword => 'パスワードを確認';

  @override
  String get alreadyHaveAccount => 'すでにアカウントをお持ちですか？';

  @override
  String get logIn => 'ログイン';

  @override
  String get createAccount => 'アカウント作成';

  @override
  String get registrationSuccess => '登録成功';

  @override
  String get confirmationSent => '確認リンクをメールに送信しました。受信トレイまたはスパムフォルダをご確認ください。';

  @override
  String get accept => '同意する';

  @override
  String get completeAllFields => 'すべての項目を入力してください';

  @override
  String get mustBe18 => '18歳以上である必要があります';

  @override
  String get passwordsDontMatch => 'パスワードが一致しません';

  @override
  String minPasswordLength(Object length) {
    return 'パスワードは$length文字以上である必要があります';
  }

  @override
  String get emailAlreadyInUse => 'このメールアドレスは既に使用されています';

  @override
  String get checkYourEmail => 'メールを確認してください！';

  @override
  String get verificationSentTo => '確認リンクを以下のアドレスに送信しました：';

  @override
  String get clickToActivate => 'メール内のリンクをクリックしてアカウントを有効化し、ログインしてください。';

  @override
  String get noEmailCheckSpam => 'メールが届きませんか？スパムまたは迷惑メールフォルダをご確認ください。';

  @override
  String get goToLogin => 'ログインへ';

  @override
  String get yourPreferences => 'あなたの好み';

  @override
  String get selectFavoriteGenres => 'お気に入りのジャンルを選択してパーソナライズされたおすすめを受け取りましょう';

  @override
  String get favoriteGenres => 'お気に入りのジャンル';

  @override
  String get contentTypes => 'コンテンツタイプ';

  @override
  String get start => '開始';

  @override
  String get skip => 'スキップ';

  @override
  String get synopsis => 'あらすじ';

  @override
  String get movedToWatchLater => '後で見るに移動しました';

  @override
  String get minutesLabel => '分';

  @override
  String get searchHintEmpty => '検索ワードを入力';

  @override
  String get noResultsSearch => '結果なし';

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
      'MovieMemoryは、マルチメディアコンテンツを発見、整理、楽しむための個人用プラットフォームです。コレクションの管理やカスタムリストの作成、コミュニティでの共有が可能です。';

  @override
  String get developer => 'Developer';

  @override
  String get credits =>
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';

  @override
  String get releaseDate => 'リリース日';

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
  String get soundSettings => 'サウンド設定';

  @override
  String get openAppSound => 'アプリ起動音';

  @override
  String get clickSound => 'クリック音';

  @override
  String get addSound => '追加音';

  @override
  String get confirmSound => '確認音';

  @override
  String get removeSound => '削除音';

  @override
  String get errorSound => 'エラー音';

  @override
  String get freesoundCredit => 'Free Commonsライセンスのサウンド';

  @override
  String get notificationSound => '通知音';

  @override
  String get supportEmail => 'サポートメール';

  @override
  String get silentMode => 'サイレントモード';

  @override
  String get silentModeDesc => 'アプリのすべてのサウンドを無効にします';

  @override
  String get playbackLanguage => '再生言語';

  @override
  String get defaultAudioLanguage => 'デフォルトの音声言語';

  @override
  String get defaultSubtitleLanguage => 'デフォルトの字幕言語';

  @override
  String get appLanguage => 'アプリの言語';

  @override
  String get systemLanguage => 'システム言語';

  @override
  String get originalLanguage => '元の言語';

  @override
  String get subtitlesDisabled => '無効';

  @override
  String get exitPlayerTitle => 'プレイヤーを終了しますか？';

  @override
  String get exitPlayerMessage => '今終了すると、現在の再生が停止します。';

  @override
  String get continueWatching => '視聴を続ける';

  @override
  String get exit => '終了';

  @override
  String get follow => 'フォローする';

  @override
  String get following => 'フォロー中';

  @override
  String get contentPreferencesNotif => '通知のコンテンツ設定';
}
