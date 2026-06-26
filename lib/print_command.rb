# frozen_string_literal: true

require_relative "command"

class PrintCommand < Command
  def initialize(lecture_room_management_information_repository, finding_date = nil, finding_subject = nil)
    if !lecture_room_management_information_repository.nil? &&
       Object.const_defined?("LectureRoomManagementInformationRepository") &&
       !lecture_room_management_information_repository.is_a?(Object.const_get("LectureRoomManagementInformationRepository"))
      raise TypeError, "lecture_room_management_information_repository must be a LectureRoomManagementInformationRepository"
    end

    raise TypeError, "finding_date must be a String" unless finding_date.nil? || finding_date.is_a?(String)
    raise TypeError, "finding_subject must be a String" unless finding_subject.nil? || finding_subject.is_a?(String)

    @lecture_room_management_information_repository = lecture_room_management_information_repository
    @finding_date = finding_date
    @finding_subject = finding_subject
  end

  def execute
    unless @lecture_room_management_information_repository.respond_to?(:find_all)
      return CommandResult.new(false, false, ErrorHandler::ERROR_LECTURE_ROOM_MANAGEMENT_INFORMATION_NOT_FOUND)
    end

    lecture_room_management_informations = @lecture_room_management_information_repository.find_all
    return CommandResult.new(false, false, ErrorHandler::ERROR_LECTURE_ROOM_MANAGEMENT_INFORMATION_NOT_FOUND) if lecture_room_management_informations.empty?

    lecture_room_management_informations = find_by_date(lecture_room_management_informations) unless @finding_date.nil?
    lecture_room_management_informations = find_by_subject(lecture_room_management_informations) unless @finding_subject.nil?
    print_all(lecture_room_management_informations)

    CommandResult.new(false, true, SUCCESS)
  end

  def print_all(lecture_room_management_informations)
    lecture_room_management_informations.each do |information|
      if Object.const_defined?("LectureRoomManagementInformationFormatter") &&
         LectureRoomManagementInformationFormatter.respond_to?(:to_formated_string)
        puts LectureRoomManagementInformationFormatter.to_formated_string(information)
      elsif Object.const_defined?("LectureRoomManagementInformationFormatter") &&
            LectureRoomManagementInformationFormatter.respond_to?(:to_formattered_string)
        puts LectureRoomManagementInformationFormatter.to_formattered_string(information)
      else
        puts information.to_s
      end
    end
  end

  def find_by_subject(lecture_room_management_informations)
    lecture_room_management_informations.select do |information|
      information.respond_to?(:subject) && information.subject == @finding_subject
    end
  end

  def find_by_date(lecture_room_management_informations)
    finding_date = @finding_date.to_s.tr("０１２３４５６７８９", "0123456789")

    lecture_room_management_informations.select do |information|
      information.respond_to?(:date) &&
        information.date.respond_to?(:month) &&
        information.date.respond_to?(:day) &&
        format("%<month>02d%<day>02d", month: information.date.month, day: information.date.day) == finding_date
    end
  end
end
