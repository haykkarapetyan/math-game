// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Math Crossword';

  @override
  String get trainYourBrain => 'Train your brain';

  @override
  String get login => 'Login';

  @override
  String get register => 'Create Account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get username => 'Username';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get orDivider => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign up';

  @override
  String get hasAccount => 'Already have an account? ';

  @override
  String get skipGuest => 'Skip, play as guest';

  @override
  String get allPages => 'All Pages';

  @override
  String get fillAllFields => 'Please fill in all fields';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String get registrationFailed =>
      'Registration failed — username or email taken';

  @override
  String get home => 'Home';

  @override
  String get score => 'Score';

  @override
  String get friends => 'Friends';

  @override
  String get profile => 'Profile';

  @override
  String get chooseATier => 'Choose a Tier';

  @override
  String grades(Object min, Object max) {
    return 'Grades $min-$max';
  }

  @override
  String get university => 'University';

  @override
  String get additionSubtraction => 'Addition & Subtraction';

  @override
  String get allOperations => 'All Operations';

  @override
  String get algebraGeometry => 'Algebra & Geometry';

  @override
  String get advancedMath => 'Advanced Math';

  @override
  String level(Object number) {
    return 'Level $number';
  }

  @override
  String tier(Object number) {
    return 'Tier $number';
  }

  @override
  String get loadingLevels => 'Loading levels...';

  @override
  String get moves => 'Moves';

  @override
  String get generatingPuzzle => 'Generating puzzle...';

  @override
  String get noPuzzleData => 'No puzzle data for this level yet';

  @override
  String undoCount(Object count) {
    return 'Undo ($count)';
  }

  @override
  String hintCount(Object count) {
    return 'Hint ($count)';
  }

  @override
  String get levelComplete => 'Level Complete!';

  @override
  String get xpEarned => 'XP Earned';

  @override
  String get wrongMoves => 'Wrong Moves';

  @override
  String get time => 'Time';

  @override
  String get levels => 'Levels';

  @override
  String get next => 'Next';

  @override
  String get gameOver => 'Game Over';

  @override
  String get outOfHearts => 'You ran out of hearts! Try again?';

  @override
  String get backToLevels => 'Back to Levels';

  @override
  String get retry => 'Retry';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get global => 'Global';

  @override
  String get inviteFriends => 'Invite Friends';

  @override
  String get inviteReward => 'Get +50 coins & +3 energy each!';

  @override
  String get invite => 'Invite';

  @override
  String online(Object count) {
    return '$count Online';
  }

  @override
  String total(Object count) {
    return '$count Total';
  }

  @override
  String get challenge => 'Challenge';

  @override
  String get shareInviteLink => 'Share Invite Link';

  @override
  String get sms => 'SMS';

  @override
  String get telegram => 'Telegram';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get copy => 'Copy';

  @override
  String get chooseAvatar => 'Choose Avatar';

  @override
  String get achievements => 'Achievements';

  @override
  String get firstWin => 'First Win';

  @override
  String get sevenDayStreak => '7-Day Streak';

  @override
  String get topTen => 'Top 10';

  @override
  String get mathGenius => 'Math Genius';

  @override
  String get xp => 'XP';

  @override
  String get stars => 'Stars';

  @override
  String get coins => 'Coins';

  @override
  String get energy => 'Energy';

  @override
  String get streak => 'Streak';

  @override
  String starsCollected(Object count) {
    return '$count stars collected';
  }
}
