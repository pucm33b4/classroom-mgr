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
  ERROR_OUTPUT_FILE_NOT_SPECIFIED = 17
  ERROR_MANAGED_LECTURE_ROOM_NOT_SELECTED = 18
  ERROR_NOT_IMPLEMENTED = 900
  ERROR_COMMAND_NOT_IMPLEMENTED = 901

  NUMBER_TO_ERROR_SENTENCE = {
    ERROR_UNKNOWN_COMMAND => "エラー: 無効なコマンドです．\nマニュアルを参照し，有効なコマンドを入力してください．",
    ERROR_ACADEMIC_CALENDAR_FILE_NOT_FOUND => "エラー：学年暦データが見つかりません．\n学年暦データを「2026/学年暦/ 」ディレクトリにアップロードしてください．",
    ERROR_ACADEMIC_CALENDAR_PARSE_FAILED => "エラー：学年暦データが読み込めません．\nファイル形式，または内容を確認してください．",
    ERROR_TIMETABLE_FILE_NOT_FOUND => "エラー：時間割データが見つかりません．\n時間割データを「2026/時間割/ 」ディレクトリにアップロードしてください．",
    ERROR_TIMETABLE_PARSE_FAILED => "エラー：時間割データが読み込めません．\nファイル形式，または内容を確認してください．",
    ERROR_RESERVATION_FILE_NOT_FOUND => "エラー：予約データが見つかりません．\n予約データを「2026/予約/ 」ディレクトリにアップロードしてください．",
    ERROR_RESERVATION_PARSE_FAILED => "エラー：予約データが読み込めません．\nファイル形式，または内容を確認してください．",
    ERROR_DIRECTORY_NOT_SPECIFIED => "エラー：ディレクトリ名が指定されていません．\nデータをアップロードしたディレクトリ名を入力してください．",
    ERROR_MANAGED_LECTURE_ROOM_FILE_NOT_FOUND => "エラー：管理対象講義室データが見つかりません．\n管理対象講義室データを「data/管理対象講義室/ 」ディレクトリにアップロードしてください．",
    ERROR_MANAGED_LECTURE_ROOM_PARSE_FAILED => "エラー：管理対象講義室データの内容が正しくありません．\n「data/管理対象講義室/ 」にある管理対象講義室データを確認してください．",
    ERROR_MANAGED_LECTURE_ROOM_NOT_LOADED => "エラー：管理対象講義室データが読み込まれていません．\n「select 」コマンドを実行してください．",
    ERROR_ACADEMIC_CALENDAR_NOT_LOADED => "エラー：学年暦データが読み込まれていません．\n「read 」コマンドを実行してください．",
    ERROR_TIMETABLE_NOT_LOADED => "エラー：時間割データが読み込まれていません．\n「read 」コマンドを実行してください．",
    ERROR_RESERVATION_NOT_LOADED => "エラー：予約データが読み込まれていません．\n「read 」コマンドを実行してください．",
    ERROR_UNKNOWN_OPTION => "エラー: 無効なオプションです．\nマニュアルを参照し，有効なオプションを入力してください．",
    ERROR_LECTURE_ROOM_MANAGEMENT_INFORMATION_NOT_FOUND => "エラー: 講義室管理情報が見つかりません．\n「create 」コマンドを実行してください．",
    ERROR_OUTPUT_FILE_NOT_SPECIFIED => "エラー: 講義室管理一覧表のファイル名を指定してください．",
    ERROR_MANAGED_LECTURE_ROOM_NOT_SELECTED => "エラー：管理対象講義室は設定されませんでした．\n管理対象講義室データを確認し，内容を更新してください．",
    ERROR_NOT_IMPLEMENTED => "エラー: この処理はまだ実装されていません．",
    ERROR_COMMAND_NOT_IMPLEMENTED => "エラー: このコマンドはまだ実装されていません．"
  }.freeze

  class << self
    def print_error(error_number)
      validate_error_number(error_number)

      error_sentence = find_error(error_number)
      raise KeyError, "undefined error number: #{error_number}" if error_sentence.nil?

      puts error_sentence
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
