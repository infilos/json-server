import 'dart:io';

class Log {

  static info(String message) {
    stdout.write('[INFO] ${message}\n');
  }

  static warn(String message) {
    stdout.write('[WARN] ${message}\n');
  }

  static error(String message) {
    stdout.write('[ERROR] ${message}\n');
  }
}