/// Versão injetada no build pelo CI:
///   --dart-define=APP_VERSION=0.2.0
/// Em desenvolvimento local fica "dev".
class AppInfo {
  AppInfo._();

  static const version =
      String.fromEnvironment('APP_VERSION', defaultValue: 'dev');

  static String get label => version == 'dev' ? 'dev' : 'v$version';
}
