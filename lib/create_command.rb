# frozen_string_literal: true

require_relative "command"

class CreateCommand < Command
  def initialize(
    lecture_room_management_information_repository,
    academic_calendar_information_repository,
    timetable_information_repository,
    reservation_information_repository,
    managed_lecture_room_information_repository,
    interactive_menu,
    term
  )
    # 各リポジトリや対話メニューが他担当クラスとして定義済みなら型を確認する。
    if !lecture_room_management_information_repository.nil? &&
       Object.const_defined?("LectureRoomManagementInformationRepository") &&
       !lecture_room_management_information_repository.is_a?(Object.const_get("LectureRoomManagementInformationRepository"))
      raise TypeError, "lecture_room_management_information_repository must be a LectureRoomManagementInformationRepository"
    end

    if !academic_calendar_information_repository.nil? &&
       Object.const_defined?("AcademicCalendarInformationRepository") &&
       !academic_calendar_information_repository.is_a?(Object.const_get("AcademicCalendarInformationRepository"))
      raise TypeError, "academic_calendar_information_repository must be an AcademicCalendarInformationRepository"
    end

    if !timetable_information_repository.nil? &&
       Object.const_defined?("TimetableInformationRepository") &&
       !timetable_information_repository.is_a?(Object.const_get("TimetableInformationRepository"))
      raise TypeError, "timetable_information_repository must be a TimetableInformationRepository"
    end

    if !reservation_information_repository.nil? &&
       Object.const_defined?("ReservationInformationRepository") &&
       !reservation_information_repository.is_a?(Object.const_get("ReservationInformationRepository"))
      raise TypeError, "reservation_information_repository must be a ReservationInformationRepository"
    end

    if !managed_lecture_room_information_repository.nil? &&
       Object.const_defined?("ManagedLectureRoomInformationRepository") &&
       !managed_lecture_room_information_repository.is_a?(Object.const_get("ManagedLectureRoomInformationRepository"))
      raise TypeError, "managed_lecture_room_information_repository must be a ManagedLectureRoomInformationRepository"
    end

    if !interactive_menu.nil? &&
       Object.const_defined?("InteractiveMenu") &&
       !interactive_menu.is_a?(Object.const_get("InteractiveMenu"))
      raise TypeError, "interactive_menu must be an InteractiveMenu"
    end

    raise TypeError, "term must be an Integer" unless term.nil? || term.is_a?(Integer)

    @lecture_room_management_information_repository = lecture_room_management_information_repository
    @academic_calendar_information_repository = academic_calendar_information_repository
    @timetable_information_repository = timetable_information_repository
    @reservation_information_repository = reservation_information_repository
    @managed_lecture_room_information_repository = managed_lecture_room_information_repository
    @interactive_menu = interactive_menu
    @term = term
  end

  def execute
    # 講義室管理情報生成に必要な入力リポジトリと出力リポジトリが使えるか確認する。
    unless @managed_lecture_room_information_repository.respond_to?(:find_all) &&
           @academic_calendar_information_repository.respond_to?(:find_all) &&
           @timetable_information_repository.respond_to?(:find_all) &&
           @reservation_information_repository.respond_to?(:find_all) &&
           @lecture_room_management_information_repository.respond_to?(:replace_all)
      return CommandResult.new(false, false, ErrorHandler::ERROR_NOT_IMPLEMENTED)
    end

    # 情報生成Factoryと競合解決Serviceは他担当のため，未定義なら未実装扱いにする。
    unless Object.const_defined?("LectureRoomManagementInformationFactory") &&
           Object.const_defined?("InteractiveConflictResolutionService")
      return CommandResult.new(false, false, ErrorHandler::ERROR_NOT_IMPLEMENTED)
    end

    # select/read コマンドで必要データが読み込まれているか確認する。
    managed_lecture_room_informations = @managed_lecture_room_information_repository.find_all
    return CommandResult.new(false, false, ErrorHandler::ERROR_MANAGED_LECTURE_ROOM_NOT_LOADED) if managed_lecture_room_informations.empty?

    academic_calendar_informations = @academic_calendar_information_repository.find_all
    return CommandResult.new(false, false, ErrorHandler::ERROR_ACADEMIC_CALENDAR_NOT_LOADED) if academic_calendar_informations.empty?

    timetable_informations = @timetable_information_repository.find_all
    return CommandResult.new(false, false, ErrorHandler::ERROR_TIMETABLE_NOT_LOADED) if timetable_informations.empty?

    reservation_informations = @reservation_information_repository.find_all
    return CommandResult.new(false, false, ErrorHandler::ERROR_RESERVATION_NOT_LOADED) if reservation_informations.empty?

    # create -t が指定されている場合は，対象学期のデータだけに絞り込む。
    if @term
      term_by_date = academic_calendar_informations.to_h { |information| [information.date, information.term] }
      academic_calendar_informations = academic_calendar_informations.select { |information| information.term == @term }
      timetable_informations = timetable_informations.select { |information| information.term == @term }
      reservation_informations = reservation_informations.select { |information| term_by_date[information.date] == @term }
    end

    # 時間割情報と予約情報から講義室管理情報を作り，競合解決後に保存する。
    begin
      factory = LectureRoomManagementInformationFactory.new(academic_calendar_informations, managed_lecture_room_informations)
      created =
        factory.create_from_timetable_informations(timetable_informations) +
        factory.create_from_reservation_informations(reservation_informations)
      service = InteractiveConflictResolutionService.new(@interactive_menu)
      resolved = service.execute(created)
      @lecture_room_management_information_repository.replace_all(resolved)
    rescue StandardError
      return CommandResult.new(false, false, ErrorHandler::ERROR_NOT_IMPLEMENTED)
    end

    # 競合があった場合だけ，解消件数も表示する。
    conflict_count = service.respond_to?(:conflicts) ? service.conflicts.size : 0
    if conflict_count.positive?
      puts "#{conflict_count}件の競合を解消しました。"
      puts "講義室管理情報を作成が完了しました。"
    else
      puts "講義室管理情報の作成が完了しました。"
    end

    CommandResult.new(false, true, SUCCESS)
  end
end
