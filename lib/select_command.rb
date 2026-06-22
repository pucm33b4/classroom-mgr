# frozen_string_literal: true

require_relative "command"

class SelectCommand < Command
  attr_reader :managed_lecture_room_information_repository, :interactive_menu

  def initialize(managed_lecture_room_information_repository, interactive_menu)
    validate_class_if_defined(
      managed_lecture_room_information_repository,
      "ManagedLectureRoomInformationRepository",
      "managed_lecture_room_information_repository"
    )
    validate_class_if_defined(interactive_menu, "InteractiveMenu", "interactive_menu")

    @managed_lecture_room_information_repository = managed_lecture_room_information_repository
    @interactive_menu = interactive_menu
  end

  def execute
    dummy_result
  end
end
