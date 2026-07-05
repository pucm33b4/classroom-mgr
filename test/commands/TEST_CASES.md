# SelectCommand Test Cases

## `select_command_unit_test.rb`

- `new` creates a `SelectCommand` instance
- `new` rejects an invalid repository
- `new` rejects an invalid interactive menu
- Missing workbook returns the managed lecture room file-not-found error
- Multiple workbooks return the managed lecture room parse error
- Empty parser output returns the managed lecture room parse error
- A room name outside the allowed list returns the managed lecture room parse error
- Equivalent abbreviated and full room names are accepted
- Full-width letters and numbers are accepted during validation
- The room names written in the XLSX are preserved in the repository
- Selecting `yes` replaces all repository entries and returns success
- Selecting `no` leaves the repository unchanged and returns the not-selected error

## `manual_check.rb`

- Runs `SelectCommand` with the real XLSX loader, parser, repository, and interactive menu
- Creates and later removes a temporary XLSX when no input XLSX exists
- Uses an existing XLSX when exactly one file is already present
- Run directly with `ruby test/commands/manual_check.rb`
