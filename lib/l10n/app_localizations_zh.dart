// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'MovieMemory';

  @override
  String get discover => '发现';

  @override
  String get search => '搜索';

  @override
  String get searchHint => '搜索电影、剧集...';

  @override
  String get library => '收藏';

  @override
  String get profile => '个人资料';

  @override
  String get myLibrary => '我的收藏';

  @override
  String get watchLater => '稍后观看';

  @override
  String get watched => '已观看';

  @override
  String get favorites => '收藏';

  @override
  String get customLists => '我的列表';

  @override
  String get listsNav => '列表';

  @override
  String get createList => '创建列表';

  @override
  String get createListTitle => '新列表';

  @override
  String get listName => '列表名称';

  @override
  String get listDescription => '描述（可选）';

  @override
  String get cancel => '取消';

  @override
  String get create => '创建';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get confirm => '确认';

  @override
  String get close => '关闭';

  @override
  String get deleteListTitle => '删除列表';

  @override
  String deleteListMessage(Object name) {
    return '删除\"$name\"？';
  }

  @override
  String get deleteItemTitle => '删除项目';

  @override
  String deleteItemMessage(Object name) {
    return '从列表中删除\"$name\"？';
  }

  @override
  String get saveChangesTitle => '保存更改';

  @override
  String get saveChangesMessage => '保存所做的更改？';

  @override
  String get emptyList => '此列表为空';

  @override
  String itemsCount(Object count) {
    return '$count个项目';
  }

  @override
  String get noResults => '此类别中没有结果';

  @override
  String get nothingHere => '这里还没有内容';

  @override
  String get tryOtherCategory => '尝试选择其他类别';

  @override
  String get searchAndAdd => '搜索电影、剧集等内容，整理您的列表，并与社区分享您的发现。';

  @override
  String get createFirstList => '创建您的第一个自定义列表';

  @override
  String get all => '全部';

  @override
  String get movie => '电影';

  @override
  String get series => '剧集';

  @override
  String get anime => '动漫';

  @override
  String get cartoon => '卡通';

  @override
  String get documentary => '纪录片';

  @override
  String get concert => '音乐会';

  @override
  String get other => '其他';

  @override
  String get noSynopsis => '暂无简介';

  @override
  String get inYourLibrary => '在您的收藏中';

  @override
  String get actions => '操作';

  @override
  String get addToWatchLater => '稍后观看';

  @override
  String get markAsWatched => '已观看';

  @override
  String get addToFavorites => '添加到收藏';

  @override
  String get removeFromFavorites => '从收藏中移除';

  @override
  String get moveToWatchLater => '移到稍后观看';

  @override
  String get markAsWatchedAction => '标记为已观看';

  @override
  String get removeFromLibrary => '从收藏中移除';

  @override
  String get addedToFavorites => '已添加到收藏';

  @override
  String get addedToWatchLater => '已添加到稍后观看';

  @override
  String get markedAsWatched => '已标记为已观看';

  @override
  String get addedToLibrary => '已添加到收藏';

  @override
  String get removedFromLibrary => '已从收藏中移除';

  @override
  String get errorLoading => '加载错误';

  @override
  String get error => '错误';

  @override
  String get loggedInAs => '已通过Google登录';

  @override
  String get memberSince => '成员自';

  @override
  String get total => '总计';

  @override
  String get viewed => '已观看';

  @override
  String get logout => '退出登录';

  @override
  String get logoutTitle => '您要退出登录吗？';

  @override
  String get logoutMessage => '您需要重新登录才能访问您的帐户。';

  @override
  String get editProfile => '编辑个人资料';

  @override
  String get settings => '设置';

  @override
  String get firstName => '名';

  @override
  String get lastName => '姓';

  @override
  String get age => '年龄';

  @override
  String get email => '邮箱';

  @override
  String get gender => '性别';

  @override
  String get bio => '简介';

  @override
  String get photoURL => '头像URL';

  @override
  String get male => '男';

  @override
  String get female => '女';

  @override
  String get nonBinary => '非二元性别';

  @override
  String get preferNotToSay => '不愿透露';

  @override
  String get otherGender => '其他';

  @override
  String get profileUpdated => '个人资料已成功更新';

  @override
  String get profileUpdateError => '更新个人资料时出错';

  @override
  String get language => '语言';

  @override
  String get spanish => '西班牙语';

  @override
  String get english => '英语';

  @override
  String get portuguese => '葡萄牙语';

  @override
  String get italian => '意大利语';

  @override
  String get french => '法语';

  @override
  String get russian => '俄语';

  @override
  String get korean => '韩语';

  @override
  String get japanese => '日语';

  @override
  String get chinese => '中文';

  @override
  String get share => '分享';

  @override
  String shareMovie(Object title, Object type) {
    return '看看这个$type：$title';
  }

  @override
  String shareMovieDescription(Object overview) {
    return '$overview';
  }

  @override
  String shareList(Object name) {
    return '列表：$name';
  }

  @override
  String shareListDescription(Object count, Object description) {
    return '$description\nMovieMemory上的$count个项目';
  }

  @override
  String shareListItems(Object name) {
    return '$name中的内容：';
  }

  @override
  String get addToList => '添加到列表';

  @override
  String get addToListTitle => '添加到列表';

  @override
  String get selectList => '选择一个列表';

  @override
  String get addedToList => '已添加到列表';

  @override
  String get editList => '编辑列表';

  @override
  String get editListTitle => '编辑列表';

  @override
  String get newFieldRequired => '此字段为必填';

  @override
  String get fieldRequired => '此字段为必填';

  @override
  String get invalidEmail => '无效的邮箱';

  @override
  String get ageRange => '必须在0到150之间';

  @override
  String get saveConfirmation => '保存更改？';

  @override
  String get typeMovie => '电影';

  @override
  String get typeSeries => '剧集';

  @override
  String get markAsWatchedShort => '已看';

  @override
  String get favoriteShort => '收藏';

  @override
  String get signOut => '退出';

  @override
  String get loading => '加载中...';

  @override
  String get retry => '重试';

  @override
  String get noItemsInList => '此列表中没有项目';

  @override
  String get listInfo => '列表信息';

  @override
  String get searchResults => '搜索结果';

  @override
  String get user => '用户';

  @override
  String get trending => '今日趋势';

  @override
  String get nowPlaying => '正在热映';

  @override
  String get popularMovies => '热门电影';

  @override
  String get popularTv => '热门剧集';

  @override
  String get topRated => '最高评分';

  @override
  String get loginSubtitle => '探索、整理和享受多媒体内容的平台。';

  @override
  String get continueWithGoogle => '继续使用Google';

  @override
  String get or => '或';

  @override
  String get emailLabel => '邮箱';

  @override
  String get passwordLabel => '密码';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get signIn => '登录';

  @override
  String get noAccount => '没有账号？';

  @override
  String get signUp => '注册';

  @override
  String get googleSignInError => 'Google登录错误';

  @override
  String get fillAllFields => '请填写所有字段';

  @override
  String get verifyEmailFirst => '请先验证您的邮箱再登录';

  @override
  String get wrongCredentials => '账号或密码错误';

  @override
  String get loginError => '登录错误';

  @override
  String get enterEmailFirst => '请先输入邮箱';

  @override
  String get recoveryEmailSent => '恢复邮件已发送';

  @override
  String get registerTitle => '创建账号';

  @override
  String get registerSubtitle => '管理您的收藏、创建自定义列表并进行分享。';

  @override
  String get nameLabel => '名字';

  @override
  String get lastNameLabel => '姓氏';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get alreadyHaveAccount => '已有账号？';

  @override
  String get logIn => '登录';

  @override
  String get createAccount => '创建账号';

  @override
  String get registrationSuccess => '注册成功';

  @override
  String get confirmationSent => '确认链接已发送到您的邮箱。请查看收件箱或垃圾邮件文件夹。';

  @override
  String get accept => '确定';

  @override
  String get completeAllFields => '请填写所有字段';

  @override
  String get mustBe18 => '您必须年满18岁才能注册';

  @override
  String get passwordsDontMatch => '密码不匹配';

  @override
  String minPasswordLength(Object length) {
    return '密码至少需要$length个字符';
  }

  @override
  String get emailAlreadyInUse => '该邮箱已被使用';

  @override
  String get checkYourEmail => '检查您的邮箱！';

  @override
  String get verificationSentTo => '我们已向以下地址发送验证链接：';

  @override
  String get clickToActivate => '点击邮件中的链接激活您的账号并登录。';

  @override
  String get noEmailCheckSpam => '看不到邮件？请检查您的垃圾邮件或广告邮件文件夹。';

  @override
  String get goToLogin => '前往登录';

  @override
  String get yourPreferences => '您的偏好';

  @override
  String get selectFavoriteGenres => '选择您喜欢的类型以获得个性化推荐';

  @override
  String get favoriteGenres => '喜欢的类型';

  @override
  String get contentTypes => '内容类型';

  @override
  String get start => '开始';

  @override
  String get skip => '跳过';

  @override
  String get synopsis => '剧情简介';

  @override
  String get movedToWatchLater => '已移至稍后观看';

  @override
  String get minutesLabel => '分钟';

  @override
  String get searchHintEmpty => '输入关键词搜索';

  @override
  String get noResultsSearch => '无结果';

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
      'MovieMemory是您发现、整理和享受多媒体内容的个人平台。管理您的收藏、创建自定义列表并与社区分享。';

  @override
  String get developer => 'Developer';

  @override
  String get credits =>
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';

  @override
  String get releaseDate => '发布日期';

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
  String get soundSettings => '声音设置';

  @override
  String get openAppSound => '应用启动声音';

  @override
  String get clickSound => '点击声音';

  @override
  String get addSound => '添加声音';

  @override
  String get confirmSound => '确认声音';

  @override
  String get removeSound => '删除声音';

  @override
  String get errorSound => '错误声音';

  @override
  String get freesoundCredit => 'Free Commons许可的音效';

  @override
  String get notificationSound => '通知声音';

  @override
  String get supportEmail => '支持邮箱';

  @override
  String get silentMode => '静音模式';

  @override
  String get silentModeDesc => '禁用所有应用声音';

  @override
  String get playbackLanguage => '播放语言';

  @override
  String get defaultAudioLanguage => '默认音频语言';

  @override
  String get defaultSubtitleLanguage => '默认字幕语言';

  @override
  String get appLanguage => '应用语言';

  @override
  String get systemLanguage => '系统语言';

  @override
  String get originalLanguage => '原始语言';

  @override
  String get subtitlesDisabled => '已禁用';

  @override
  String get exitPlayerTitle => '要退出播放器吗？';

  @override
  String get exitPlayerMessage => '如果现在退出，当前播放将被停止。';

  @override
  String get continueWatching => '继续观看';

  @override
  String get exit => '退出';

  @override
  String get follow => '关注';

  @override
  String get following => '已关注';

  @override
  String get contentPreferencesNotif => '通知内容偏好设置';
}
