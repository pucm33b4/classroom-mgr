# Command Test Cases

## `command_unit_test.rb`

- `execute` returns a `CommandResult`
- Default command result is not successful
- Default command result uses `ERROR_COMMAND_NOT_IMPLEMENTED`

## `command_result_unit_test.rb`

- Valid initialization
- `exit_flag` is readable
- `is_succeed` is readable
- `error_number` is readable
- Invalid `exit_flag` type
- Invalid `is_succeed` type
- Invalid `error_number` type

## `error_handler_unit_test.rb`

- `find_error` returns an error message
- `find_error` rejects non-`Integer` input
- `print_error` outputs an error message
- `print_error` rejects undefined error numbers

## `command_factory_unit_test.rb`

- `read` creates a `ReadCommand`
- `select` creates a `SelectCommand`
- `create` creates a `CreateCommand`
- `create` converts the `term` option to an integer
- `print` with `date` option creates a `PrintCommand`
- `print` passes the `date` option to `PrintCommand`
- `print` with `subject` option creates a `PrintCommand`
- `print` passes the `subject` option to `PrintCommand`
- `write` creates a `WriteCommand`
- `quit` creates a `QuitCommand`
- Unknown command returns `nil`
- Invalid command name type
- Invalid arguments type
- Invalid options type

## `read_command_unit_test.rb`

- Invalid directory path type
- Empty directory path returns `ERROR_DIRECTORY_NOT_SPECIFIED`
- Missing academic calendar file returns `ERROR_ACADEMIC_CALENDAR_FILE_NOT_FOUND`
- Academic calendar data is loaded into the academic calendar repository
- Timetable data is loaded into the timetable repository
- Reservation data is loaded into the reservation repository
- Successful read returns `SUCCESS`

## `select_command_unit_test.rb`

- Missing managed lecture room file returns `ERROR_MANAGED_LECTURE_ROOM_FILE_NOT_FOUND`
- User acceptance stores managed lecture room information
- User acceptance returns `SUCCESS`
- User rejection returns `ERROR_MANAGED_LECTURE_ROOM_NOT_SELECTED`

## `create_command_unit_test.rb`

- Invalid `term` type
- Missing managed lecture room information returns `ERROR_MANAGED_LECTURE_ROOM_NOT_LOADED`
- Missing academic calendar information returns `ERROR_ACADEMIC_CALENDAR_NOT_LOADED`
- Timetable information is used to create lecture room management information
- Reservation information is used to create lecture room management information
- Created lecture room management information is stored in the repository
- `term` option filters timetable information
- `term` option filters reservation information by academic calendar date
- Successful creation returns `SUCCESS`

## `print_command_unit_test.rb`

- Missing lecture room management information returns `ERROR_LECTURE_ROOM_MANAGEMENT_INFORMATION_NOT_FOUND`
- `find_by_subject` returns matching records
- `find_by_date` returns matching records
- `print_all` outputs target records
- `execute` prints filtered records
- Successful print returns `SUCCESS`

## `write_command_unit_test.rb`

- Invalid output file name type
- Empty output file name returns `ERROR_OUTPUT_FILE_NOT_SPECIFIED`
- Missing lecture room management information returns `ERROR_LECTURE_ROOM_MANAGEMENT_INFORMATION_NOT_FOUND`
- Missing academic calendar information returns `ERROR_ACADEMIC_CALENDAR_NOT_LOADED`
- Lecture room management table is built
- Lecture room management information is populated into the output workbook
- Workbook is passed to the Excel data exporter
- Output file name is passed to the Excel data exporter
- Successful write returns `SUCCESS`

## `quit_command_unit_test.rb`

- `execute` outputs a termination message
- `execute` returns a successful `CommandResult`
- `exit_flag` is `true`
- `is_succeed` is `true`
- `error_number` is `SUCCESS`
