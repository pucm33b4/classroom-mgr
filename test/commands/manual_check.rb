# frozen_string_literal: true

require "fileutils"
require_relative "../../lib/select_command"

directory_path = File.join("data", "管理対象講義室")
created_file_path = nil

begin
  FileUtils.mkdir_p(directory_path)
  xlsx_files = Dir.glob(File.join(directory_path, "*.xlsx"))

  if xlsx_files.empty?
    created_file_path = File.join(directory_path, "select_command_manual_check.xlsx")
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    worksheet.add_cell(0, 0, "第10講義室")
    worksheet.add_cell(1, 0, "第11講義室")
    worksheet.add_cell(2, 0, "303室")
    workbook.write(created_file_path)
    puts "検証用XLSXを作成しました: #{created_file_path}"
  elsif xlsx_files.one?
    puts "既存のXLSXを使用します: #{xlsx_files.first}"
  else
    puts "XLSXが複数存在するため，エラー番号10の確認を行います．"
  end

  repository = ManagedLectureRoomInformationRepository.new
  command = SelectCommand.new(repository, InteractiveMenu.new)
  result = command.execute

  ErrorHandler.print_error(result.error_number) unless result.is_succeed

  puts
  puts "実行結果"
  puts "exit_flag: #{result.exit_flag}"
  puts "is_succeed: #{result.is_succeed}"
  puts "error_number: #{result.error_number}"
  puts "保存された講義室: #{repository.find_all.map(&:room_name).inspect}"
ensure
  if !created_file_path.nil? && File.exist?(created_file_path)
    File.delete(created_file_path)
    puts "検証用XLSXを削除しました．"
  end
end
