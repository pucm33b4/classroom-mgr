# frozen_string_literal: true

class ErrorHandler
  ERROR_UNKNOWN_COMMAND = 1
  ERROR_ACADEMIC_CALENDAR_FILE_NOT_FOUND = 2
  ERROR_ACADEMIC_CALENDAR_PARSE_FAILED = 3
  ERROR_TIMETABLE_FILE_NOT_FOUND = 4
  ERROR_TIMETABLE_PARSE_FAILED = 5
  ERROR_RESERVATION_FILE_NOT_FOUND = 6
  ERROR_RESERVATION_PARSE_FAILED = 7
  ERROR_DIRECTORY_NOT_SPECIFIED = 8
  ERROR_MANAGED_LECTURE_ROOM_FILE_NOT_FOUND = 9
  ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED = 10
  ERROR_MANAGED_LECTURE_ROOM_NOT_LOADED = 11
  ERROR_ACADEMIC_CALENDAR_NOT_LOADED = 12
  ERROR_TIMETABLE_NOT_LOADED = 13
  ERROR_RESERVATION_NOT_LOADED = 14
  ERROR_UNKNOWN_OPTION = 15
  ERROR_LECTURE_ROOM_MANAGEMENT_INFORMATION_NOT_FOUND = 16
  ERROR_NOT_IMPLEMENTED = 900
  ERROR_COMMAND_NOT_IMPLEMENTED = 901

  NUMBER_TO_ERROR_SENTENCE = {
    ERROR_UNKNOWN_COMMAND => "存在しないコマンドが入力されました。",
    ERROR_ACADEMIC_CALENDAR_FILE_NOT_FOUND => "学年暦データが存在しません。",
    ERROR_ACADEMIC_CALENDAR_PARSE_FAILED => "学年暦に関する構造化データが作成できませんでした。",
    ERROR_TIMETABLE_FILE_NOT_FOUND => "時間割データが存在しません。",
    ERROR_TIMETABLE_PARSE_FAILED => "時間割に関する構造化データが作成できませんでした。",
    ERROR_RESERVATION_FILE_NOT_FOUND => "予約データが存在しません。",
    ERROR_RESERVATION_PARSE_FAILED => "予約に関する構造化データが作成できませんでした。",
    ERROR_DIRECTORY_NOT_SPECIFIED => "ディレクトリ名が指定されていません。",
    ERROR_MANAGED_LECTURE_ROOM_FILE_NOT_FOUND => "管理対象講義室データが存在しません。",
    ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED => "管理対象講義室データの内容が正しくありません。",
    ERROR_MANAGED_LECTURE_ROOM_NOT_LOADED => "講義室情報を取得していません。",
    ERROR_ACADEMIC_CALENDAR_NOT_LOADED => "学年暦に関する構造化データが存在しません。",
    ERROR_TIMETABLE_NOT_LOADED => "時間割に関する構造化データが存在しません。",
    ERROR_RESERVATION_NOT_LOADED => "予約に関する構造化データが存在しません。",
    ERROR_UNKNOWN_OPTION => "存在しないオプションが入力されました。",
    ERROR_LECTURE_ROOM_MANAGEMENT_INFORMATION_NOT_FOUND => "講義室管理情報が存在しません。",
    ERROR_NOT_IMPLEMENTED => "この処理はまだ実装されていません。",
    ERROR_COMMAND_NOT_IMPLEMENTED => "このコマンドはまだ実装されていません。"
  }.freeze

  class << self
    def print_error(error_number)
      validate_error_number(error_number)

      error_sentence = find_error(error_number)
      raise KeyError, "undefined error number: #{error_number}" if error_sentence.nil?

      puts "エラー: #{error_sentence}"
    end

    def find_error(error_number)
      validate_error_number(error_number)

      NUMBER_TO_ERROR_SENTENCE[error_number]
    end

    private

    def validate_error_number(error_number)
      return if error_number.is_a?(Integer)

      raise TypeError, "error_number must be an Integer"
    end
  end
end
