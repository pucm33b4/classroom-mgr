# frozen_string_literal: true

require "date"
require "minitest/autorun"
require "ostruct"

class TestRepository
  attr_reader :replaced_items

  def initialize(items = [])
    @items = items
    @replaced_items = nil
  end

  def find_all
    @items.dup
  end

  def replace_all(items)
    @items = items.dup
    @replaced_items = items.dup
  end
end

class LectureRoomManagementInformationRepository < TestRepository
end

class AcademicCalendarInformationRepository < TestRepository
end

class TimetableInformationRepository < TestRepository
end

class ReservationInformationRepository < TestRepository
end

class ManagedLectureRoomInformationRepository < TestRepository
end

class InteractiveMenu
  def initialize(answer = true)
    @answer = answer
  end

  def ask_yes_or_no(_message)
    @answer
  end
end

class ExcelDataExporter
  attr_reader :workbook, :file_name

  def export(workbook, file_name)
    @workbook = workbook
    @file_name = file_name
    file_name
  end
end

class ExcelDataLoader
  class << self
    attr_accessor :academic_calendar_workbook,
                  :timetable_workbook,
                  :reservation_workbook,
                  :managed_lecture_room_workbook

    def reset
      @academic_calendar_workbook = nil
      @timetable_workbook = nil
      @reservation_workbook = nil
      @managed_lecture_room_workbook = nil
    end

    def load_academic_calendar_xlsx_file(_directory_path)
      @academic_calendar_workbook
    end

    def load_timetable_xlsx_file(_directory_path)
      @timetable_workbook
    end

    def load_reservation_xlsx_file(_directory_path)
      @reservation_workbook
    end

    def load_managed_lecture_room_xlsx_file
      @managed_lecture_room_workbook
    end
  end
end

class AcademicCalendarParser
  def initialize(worksheet)
    @worksheet = worksheet
  end

  def parse_academic_calendar_worksheet
    @worksheet
  end
end

class TimetableParser
  def initialize(worksheet)
    @worksheet = worksheet
  end

  def parse_timetable_worksheet
    @worksheet
  end
end

class ReservationParser
  def initialize(worksheet)
    @worksheet = worksheet
  end

  def parse_reservation_worksheet
    @worksheet
  end
end

class ManagedLectureRoomParser
  def initialize(worksheet)
    @worksheet = worksheet
  end

  def parse_managed_lecture_room_worksheet
    @worksheet
  end
end

class LectureRoomManagementInformationFactory
  def initialize(_academic_calendar_informations, _managed_lecture_room_informations)
  end

  def create_from_timetable_informations(timetable_informations)
    timetable_informations
  end

  def create_from_reservation_informations(reservation_informations)
    reservation_informations
  end
end

class InteractiveConflictResolutionService
  attr_reader :conflicts

  def initialize(_interactive_menu)
    @conflicts = []
  end

  def execute(created_informations)
    created_informations
  end
end

class LectureRoomManagementTableBuilder
  def self.build(academic_calendar_informations)
    { academic_calendar_informations: academic_calendar_informations }
  end
end

class LectureRoomManagementTablePopulator
  def initialize(table)
    @table = table
  end

  def populate_entries(lecture_room_management_informations)
    OpenStruct.new(
      workbook: {
        table: @table,
        lecture_room_management_informations: lecture_room_management_informations
      }
    )
  end
end

class PrintableLectureRoomManagementInformation
  attr_reader :date, :subject

  def initialize(date:, subject:, label:)
    @date = date
    @subject = subject
    @label = label
  end

  def to_s
    @label
  end
end
