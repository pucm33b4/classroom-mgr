# frozen_string_literal: true

require_relative "command"

class PrintCommand < Command
  attr_reader :lecture_room_management_information_repository,
              :finding_date,
              :finding_subject

  def initialize(lecture_room_management_information_repository, finding_date = nil, finding_subject = nil)
    validate_class_if_defined(
      lecture_room_management_information_repository,
      "LectureRoomManagementInformationRepository",
      "lecture_room_management_information_repository"
    )
    validate_string(finding_date, "finding_date", allow_nil: true)
    validate_string(finding_subject, "finding_subject", allow_nil: true)

    @lecture_room_management_information_repository = lecture_room_management_information_repository
    @finding_date = finding_date
    @finding_subject = finding_subject
  end

  def execute
    return CommandResult.new(false, false, ErrorHandler::ERROR_LECTURE_ROOM_MANAGEMENT_INFORMATION_NOT_FOUND) unless repository_ready_for_read?(@lecture_room_management_information_repository)

    informations = @lecture_room_management_information_repository.find_all
    return CommandResult.new(false, false, ErrorHandler::ERROR_LECTURE_ROOM_MANAGEMENT_INFORMATION_NOT_FOUND) if informations.empty?

    informations = find_by_date(informations) unless @finding_date.nil?
    informations = find_by_subject(informations) unless @finding_subject.nil?
    print_all(informations)
    success_result
  end

  def print_all(lecture_room_management_informations)
    lecture_room_management_informations.each do |information|
      puts formatted_information(information)
    end
  end

  def find_by_subject(lecture_room_management_informations)
    lecture_room_management_informations.select do |information|
      information.subject == @finding_subject
    end
  end

  def find_by_date(lecture_room_management_informations)
    lecture_room_management_informations.select do |information|
      format("%<month>02d%<day>02d", month: information.date.month, day: information.date.day) == normalized_finding_date
    end
  end

  private

  def formatted_information(information)
    if implemented_classes?("LectureRoomManagementInformationFormatter")
      return LectureRoomManagementInformationFormatter.to_formated_string(information) if LectureRoomManagementInformationFormatter.respond_to?(:to_formated_string)
      return LectureRoomManagementInformationFormatter.to_formattered_string(information) if LectureRoomManagementInformationFormatter.respond_to?(:to_formattered_string)
    end

    information.to_s
  end

  def normalized_finding_date
    @finding_date.to_s.tr("０-９", "0-9")
  end
end
