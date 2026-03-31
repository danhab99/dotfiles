# Creating New Subcommands

This guide explains how to add new subcommands to `grit`.

**🎉 NEW:** The `main.go` file is now automatically generated from the `cmd/` directory structure! You don't need to manually edit `main.go` anymore.

## Quick Start

1. Create a new directory under `cmd/` with your command name
2. Create a `.go` file with the same name
3. Add a `// Description:` comment at the top
4. Implement `RegisterFlags()` and `Execute()` functions
5. Regenerate `main.go` by running: `nix eval --impure --raw --expr 'let flake = builtins.getFlake (toString ./.); in flake.lib.generate-main ./cmd' > main.go`

That's it! No manual editing of `main.go` required.

## File Structure

Each subcommand lives in its own package under `cmd/`:

```
cmd/
  mycommand/
    mycommand.go    # Command implementation
```

## Implementation Pattern

### 1. Create the command package

Create a new file `cmd/mycommand/mycommand.go`:

**Important:** Add a `// Description:` comment on the first line - this will be used in the generated help text!

```go
// Description: Brief description of what this command does
package mycommand

import (
	"flag"
	"fmt"
	"os"

	"grit/db"
	"grit/log"
)

var logger = log.NewLogger("MYCOMMAND")

// Command flags - package-level variables
var (
	dbPath      *string
	someOption  *string
	anotherFlag *bool
)

// RegisterFlags sets up the flags for this command
func RegisterFlags(fs *flag.FlagSet) {
	dbPath = fs.String("db", "./db", "database path")
	someOption = fs.String("option", "", "some option description")
	anotherFlag = fs.Bool("flag", false, "boolean flag description")
}

// Execute runs the command
func Execute() {
	// Validate required flags
	if *someOption == "" {
		fmt.Fprintf(os.Stderr, "Error: -option is required\n")
		os.Exit(1)
	}

	logger.Printf("Starting mycommand with option: %s\n", *someOption)

	// Open database if needed
	database, err := db.NewDatabase(*dbPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error opening database: %v\n", err)
		os.Exit(1)
	}
	defer database.Close()

	// Your command logic here
	doWork(database)

	logger.Printf("Command completed\n")
}

func doWork(database db.Database) {
	// Implementation...
}
```

### 2. Regenerate main.go

Run the generator to update `main.go`:

```bash
# Using Nix
nix eval --impure --raw --expr 'let flake = builtins.getFlake (toString ./.); in flake.lib.generate-main ./cmd' > main.go

# Or use the helper script (TODO: needs update)
# ./scripts/gen-main.sh
```

That's it! The new command is now registered and ready to use.

### 3. Build and test

```bash
# Build
go build -o grit .

# Test help
./grit mycommand -h

# Run command
./grit mycommand -option value -flag
```

## Key Points

- **Package name**: Must match the directory name (e.g., `package mycommand`)
- **Two required functions**: `RegisterFlags(fs *flag.FlagSet)` and `Execute()`
- **Flag variables**: Declare as package-level pointers (assigned in RegisterFlags)
- **Error handling**: Print to stderr and exit with non-zero code
- **Database**: Remember to `defer database.Close()` if you open it
- **Logger**: Create package-level logger: `var logger = log.NewLogger("MYCOMMAND")`

## Existing Examples

- **`run`** ([cmd/run/run.go](run/run.go)) - Complex command with manifest loading, pipeline execution
- **`export`** ([cmd/export/export.go](export/export.go)) - Simple command with database queries
- **`status`** ([cmd/status/status.go](status/status.go)) - Status display with multiple database calls

## Testing Checklist

- [ ] `./grit mycommand -h` shows help
- [ ] Required flags are validated
- [ ] Error messages go to stderr
- [ ] Exit codes are appropriate (0 for success, non-zero for errors)
- [ ] Command appears in main help (`./grit`)
Description comment**: First line should be `// Description: Your description here`
- **Two required functions**: `RegisterFlags(fs *flag.FlagSet)` and `Execute()`
- **Flag variables**: Declare as package-level pointers (assigned in RegisterFlags)
- **Error handling**: Print to stderr and exit with non-zero code
- **Database**: Remember to `defer database.Close()` if you open it
- **Logger**: Create package-level logger: `var logger = log.NewLogger("MYCOMMAND")`
- **No manual main.go edits**: The file is auto-generated - just regenerate it!

## How the Auto-Generation Works

The Nix expression in `nix/gen-main.nix`:
1. Scans all directories in `cmd/`
2. Extracts the `// Description:` comment from each command's `.go` file
3. Generates import statements for all found commands
4. Creates switch cases for each command
5. Builds the usage text with aligned descriptions

This means:
- ✅ Adding a new command = just create the directory and file
- ✅ No risk of forgetting to register a command
- ✅ Consistent code structure
- ✅ Descriptions stay in sync with the code

## Nix Build Integration

When building with Nix (`nix build`), the `flake.nix` automatically generates `main.go` before compilation, so the built binary always has all available commands.