// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Мath Кроссворд';

  @override
  String get trainYourBrain => 'Тренируй свой мозг';

  @override
  String get login => 'Войти';

  @override
  String get register => 'Создать аккаунт';

  @override
  String get email => 'Эл. почта';

  @override
  String get password => 'Пароль';

  @override
  String get username => 'Имя пользователя';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get orDivider => 'или';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get continueWithApple => 'Продолжить с Apple';

  @override
  String get noAccount => 'Нет аккаунта? ';

  @override
  String get signUp => 'Регистрация';

  @override
  String get hasAccount => 'Уже есть аккаунт? ';

  @override
  String get skipGuest => 'Пропустить, играть как гость';

  @override
  String get allPages => 'Все страницы';

  @override
  String get fillAllFields => 'Заполните все поля';

  @override
  String get invalidCredentials => 'Неверный email или пароль';

  @override
  String get registrationFailed => 'Ошибка — имя или email заняты';

  @override
  String get home => 'Главная';

  @override
  String get score => 'Рейтинг';

  @override
  String get friends => 'Друзья';

  @override
  String get profile => 'Профиль';

  @override
  String get chooseATier => 'Выберите уровень';

  @override
  String grades(Object min, Object max) {
    return 'Классы $min-$max';
  }

  @override
  String get university => 'Университет';

  @override
  String get additionSubtraction => 'Сложение и вычитание';

  @override
  String get allOperations => 'Все операции';

  @override
  String get algebraGeometry => 'Алгебра и геометрия';

  @override
  String get advancedMath => 'Высшая математика';

  @override
  String level(Object number) {
    return 'Уровень $number';
  }

  @override
  String tier(Object number) {
    return 'Этап $number';
  }

  @override
  String get loadingLevels => 'Загрузка уровней...';

  @override
  String get moves => 'Ходы';

  @override
  String get generatingPuzzle => 'Генерация задачи...';

  @override
  String get noPuzzleData => 'Нет данных для этого уровня';

  @override
  String undoCount(Object count) {
    return 'Отмена ($count)';
  }

  @override
  String hintCount(Object count) {
    return 'Подсказка ($count)';
  }

  @override
  String get levelComplete => 'Уровень пройден!';

  @override
  String get xpEarned => 'Получено XP';

  @override
  String get wrongMoves => 'Ошибки';

  @override
  String get time => 'Время';

  @override
  String get levels => 'Уровни';

  @override
  String get next => 'Далее';

  @override
  String get gameOver => 'Игра окончена';

  @override
  String get outOfHearts => 'Сердца закончились! Попробовать снова?';

  @override
  String get backToLevels => 'К уровням';

  @override
  String get retry => 'Заново';

  @override
  String get leaderboard => 'Таблица лидеров';

  @override
  String get global => 'Мировой';

  @override
  String get inviteFriends => 'Пригласить друзей';

  @override
  String get inviteReward => '+50 монет и +3 энергии каждому!';

  @override
  String get invite => 'Пригласить';

  @override
  String online(Object count) {
    return '$count Онлайн';
  }

  @override
  String total(Object count) {
    return '$count Всего';
  }

  @override
  String get challenge => 'Вызов';

  @override
  String get shareInviteLink => 'Поделиться ссылкой';

  @override
  String get sms => 'SMS';

  @override
  String get telegram => 'Telegram';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get copy => 'Копировать';

  @override
  String get chooseAvatar => 'Выберите аватар';

  @override
  String get achievements => 'Достижения';

  @override
  String get firstWin => 'Первая победа';

  @override
  String get sevenDayStreak => '7 дней подряд';

  @override
  String get topTen => 'Топ 10';

  @override
  String get mathGenius => 'Математический гений';

  @override
  String get xp => 'XP';

  @override
  String get stars => 'Звёзды';

  @override
  String get coins => 'Монеты';

  @override
  String get energy => 'Энергия';

  @override
  String get streak => 'Серия';

  @override
  String starsCollected(Object count) {
    return '$count звёзд собрано';
  }
}
