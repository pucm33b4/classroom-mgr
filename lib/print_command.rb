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
    dummy_result
  end
end
