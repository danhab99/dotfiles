# G.R.I.T

> Go Runtime for Iterative Tasks

A Go-based data pipeline system that executes shell scripts in a managed workflow with persistent state tracking using a dual-database architecture (SQLite + BadgerDB) and a FUSE filesystem for efficient resource management.

```
     ┌─────────────┐
     │   Manifest  │
     │  (TOML def) │
     └──────┬──────┘
            │
            ▼
     ┌─────────────┐     ┌──────────────────────┐
     │  Register   │────▶│  Dual Database       │
     │    Steps    │     │  SQLite: Metadata    │
     └──────┬──────┘     │  BadgerDB: Objects   │
            │            └──────────────────────┘
            ▼
     ┌───────────────────────────┐
     │  Create Resources         │◀──── Seed task (start step)
     │  (from seed or existing)  │
     └─────────────┬─────────────┘
                   │
                   ▼
     ┌─────────────────────────────┐
     │  For each step:             │
     │  1. Schedule tasks from     │
     │     unconsumed resources    │
     │  2. Execute in parallel     │
     │     (FUSE collects output)  │
     │  3. Create new resources    │
     └─────────────────────────────┘
```

## Quick Start

### Using Nix Flakes

#### Build with Nix
```bash
nix build
./result/bin/grit --help
```

#### Run directly
```bash
nix run . -- -manifest workflow.toml -db ./db -run
```

#### Add to your NixOS configuration

Add this flake as an input to your NixOS configuration flake:

```nix
# In your NixOS flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    grit = {
      url = "github:danhab99/grit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, grit, ... }: {
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        {
          # Add to system packages
          environment.systemPackages = [
            grit.packages.x86_64-linux.default
          ];
        }
      ];
    };
  };
}
```

After rebuilding your system, `grit` will be available system-wide:
```bash
sudo nixos-rebuild switch --flake .#yourhostname
grit --help
```

Alternatively, add it to your home-manager configuration:
```nix
# In home.nix or similar
{ inputs, ... }:
{
  home.packages = [
    inputs.grit.packages.x86_64-linux.default
  ];
}
```

### Build without Nix
```bash
go build -o grit
```

### Run a Pipeline
```bash
./grit -manifest workflow.toml -db ./my-pipeline-db -run
```

### Create a Manifest (workflow.toml)
```toml
[[step]]
name = "start"
# No inputs specified - this is a starter step
script = '''
echo "Input data" > $OUTPUT_DIR/dataset-v1
echo "More data" > $OUTPUT_DIR/dataset-v2
'''

[[step]]
name = "process"
inputs = ["dataset-v1"]  # Filter: only process resources named "dataset-v1"
script = '''
cat $INPUT_FILE | tr '[:lower:]' '[:upper:]' > $OUTPUT_DIR/processed
'''

[[step]]
name = "transform"
inputs = ["dataset-v2"]  # Filter: only process resources named "dataset-v2"
parallel = 2             # Limit to 2 concurrent tasks for this step
script = '''
cat $INPUT_FILE | sort > $OUTPUT_DIR/sorted
'''
```

### Common Commands
```bash
# Run the pipeline
./grit -manifest manifest.toml --db ./db -run

# Run with parallel limit
./grit -manifest manifest.toml --db ./db -run -parallel 4

# Specify starting step
./grit -manifest manifest.toml --db ./db -run -start process_name

# Filter to specific steps (can be used multiple times)
./grit -manifest manifest.toml --db ./db -run -step process_name -step transform_name

# Export resources by name
./grit -manifest manifest.toml --db ./db -export dataset-v1

# Export resource content by hash
./grit -manifest manifest.toml --db ./db -export-hash <sha256-hash>

# Run with verbose output (see detailed task and script information)
./grit -manifest manifest.toml --db ./db -run -verbose

# Run with minimal output (for automation/CI)
./grit -manifest manifest.toml --db ./db -run -quiet
```

## Overview

GRIT (Go Runtime for Iterative Tasks) is a workflow automation tool that:
- Executes tasks defined in a TOML manifest file
- Stores task execution state and metadata in SQLite
- Stores task outputs (resources) in BadgerDB using content-addressable storage
- Manages task inputs/outputs through a write-only FUSE filesystem
- Supports task chaining through resource-based dependencies
- Processes multiple task streams concurrently with configurable parallelism
- Automatically tracks step versioning when scripts change
- Implements incremental processing by only creating tasks for unconsumed resources

## Development

### Nix Development Shell
```bash
# Enter development environment with all dependencies
nix develop

# Now you have go, gopls, delve, sqlite, etc.
go build
go test
```

## Releases

### CI/CD

This project uses GitHub Actions for continuous integration and releases:

- **CI Workflow** (`.github/workflows/ci.yml`): Runs on every push and pull request
  - Checks flake validity
  - Builds the project
  - Tests the binary
  - Runs basic pipeline tests

- **Release Workflow** (`.github/workflows/release.yml`): Runs when you push a tag
  - Builds release binaries using Nix
  - Creates GitHub releases automatically
  - Attaches binaries to the release

### Creating a Release

Releases are automated via GitHub Actions. To create a new release:

1. **Tag the commit:**
   ```bash
   git tag v0.1.0
   git push origin v0.1.0
   ```

2. **GitHub Actions will automatically:**
   - Build the binary using Nix
   - Create a GitHub release
   - Attach the compiled binary (`grit-linux-x86_64`)
   - Generate installation instructions

3. **Users can then:**
   - Download the binary directly from the release page
   - Use `nix run github:danhab99/grit/v0.1.0`
   - Reference the specific version in their flake inputs

### Installing from a Release

#### Binary Download
```bash
wget https://github.com/danhab99/grit/releases/download/v0.1.0/grit-linux-x86_64
chmod +x grit-linux-x86_64
sudo mv grit-linux-x86_64 /usr/local/bin/grit
```

#### Using Nix (specific version)
```bash
nix run github:danhab99/grit/v0.1.0 -- --help
```

#### In your flake (specific version)
```nix
{
  inputs.grit.url = "github:danhab99/grit/v0.1.0";
}
```

## Architecture

The system consists of six main components:

### 1. **Main (`main.go`)**
Entry point that:
- Parses command-line flags for manifest path, database path, and execution options
- Loads and parses the TOML manifest
- Initializes the dual-database system (SQLite + BadgerDB)
- Checks disk space before execution (warns if >85% full)
- Delegates to run, export by name, or export by hash modes

### 2. **Manifest (`manifest.go`)**
Defines the pipeline structure:
- `Manifest`: Contains array of steps
- `ManifestStep`: Step properties (name, script, parallel count, inputs filter)
- Uses TOML format for declarative configuration
- Note: A starter step is any step with no inputs (no "inputs" field or empty inputs)

### 3. **Database (`db.go`)**
Manages persistent storage with dual-database architecture:
- **SQLite Database**: 
  - **steps** table: Stores step definitions with versioning (name, script, version, parallel, inputs)
  - **tasks** table: Tracks individual task executions (step_id, input_resource_id, processed, error)
  - **resources** table: Metadata for outputs (name, object_hash, created_at)
  - Indexes for efficient queries
- **BadgerDB Object Store**: 
  - Content-addressable storage using SHA-256 hashes
  - Immutable objects with batch operations support
  - Optimized for write-heavy workloads (128MB memtable)
  - Efficient large value log handling

### 4. **Pipeline (`pipeline.go`)**
Orchestrates task execution:
- Creates per-step FUSE filesystem for output collection
- Schedules tasks from unconsumed resources matching step inputs
- Executes unprocessed tasks in parallel using worker pools
- Manages resource-to-task flow with channel-based streaming

### 5. **Executor (`executor.go`)**
Runs individual tasks:
- Fetches input resource from BadgerDB and writes to temporary file
- Mounts write-only FUSE filesystem for task output directory
- Executes shell script with environment variables (INPUT_FILE, OUTPUT_DIR)
- Captures stdout/stderr with per-task logging
- Collects outputs from FUSE and stores as new resources

### 6. **FUSE Watcher (`fuse_watcher.go`)**
Write-only filesystem for task outputs:
- Mounts temporary FUSE filesystem at `/tmp/output-*`
- Captures file writes from scripts and converts to resources
- Supports file rewrites (later writes replace earlier ones)
- Implements graceful shutdown with 2-second timeout
- Provides backpressure control via buffered channels
- Disables directory listing and read operations for isolation

## Resource Model & Data Flow

GRIT uses a **resource-based execution model** where data flows through the pipeline as named resources:

### How It Works

1. **Resources are Created**: Scripts write files to `$OUTPUT_DIR`, which is a FUSE mount. The filename becomes the resource name.
   ```bash
   echo "data" > $OUTPUT_DIR/my-dataset  # Creates resource named "my-dataset"
   ```

2. **Tasks are Scheduled**: When a step has an `inputs` filter, only resources matching that name trigger task creation.
   ```toml
   [[step]]
   name = "processor"
   inputs = ["my-dataset"]  # Only processes resources named "my-dataset"
   ```

3. **Incremental Processing**: The `GetUnconsumedResources()` method finds resources that haven't been processed by a step yet, enabling incremental pipelines.

4. **Seed Tasks**: Start steps (steps with no inputs) execute once with no input (`INPUT_FILE` is empty) to bootstrap the pipeline.

5. **Content Deduplication**: Resources with identical content (same SHA-256 hash) are stored only once in BadgerDB, saving disk space.

### Example Data Flow
```
Start Step
  └─> Writes "raw-data" resource
        └─> Step with inputs=["raw-data"] processes it
              └─> Writes "processed" resource
                    └─> Step with inputs=["processed"] processes it
                          └─> Writes "final" resource
```

## Usage

```bash
grit -manifest <path-to-manifest.toml> -db <database-directory> [options]
```

### Command-Line Flags

- `-manifest` (required): Path to the TOML manifest file defining steps
- `-db` (default: `./db`): Directory for database and object storage
- `-run`: Execute the pipeline
- `-parallel` (default: number of CPUs): Maximum concurrent tasks to execute
- `-start`: Name of the step to start from (defaults to steps with no inputs)
- `-step`: Filter to specific steps (can be repeated multiple times for multiple steps)
- `-export`: List all resource hashes for a given resource name
- `-export-hash`: Stream resource content by hash to stdout (for extracting pipeline outputs)
- `-verbose`: Enable detailed logging with task information, script details, and input/output operations
- `-quiet`: Minimal output mode (only critical errors, overrides verbose)

### Manifest Format

Create a TOML file with step definitions:

```toml
[[step]]
name = "extract"
# No inputs specified - this is a starter step
script = """
# Initial step - generates output files (resources)
curl https://api.example.com/data > $OUTPUT_DIR/data
"""

[[step]]
name = "process"
inputs = ["data"]  # Only process resources named "data"
script = """
# Process the data and generate output
process-tool < $INPUT_FILE > $OUTPUT_DIR/result
"""

[[step]]
name = "transform"
inputs = ["result"]  # Only process resources named "result"
parallel = 2         # Limit this step to 2 parallel tasks
script = """
# Transform and output to next step
transform-tool < $INPUT_FILE > $OUTPUT_DIR/final
"""
```

### Environment Variables for Scripts

Each step script receives:
- `INPUT_FILE`: Path to the input file (from previous step's resource, or empty for start step)
- `OUTPUT_DIR`: Path to a FUSE-mounted directory where the script writes output files

**Resource Naming:** Output filenames become resource names. For example:
- Script writes `$OUTPUT_DIR/dataset-v1` → Creates resource named "dataset-v1"
- Script writes `$OUTPUT_DIR/results` → Creates resource named "results"

**Resource Flow:** Steps can filter which resources they process using the `inputs` field:
```toml
[[step]]
name = "processor"
inputs = ["dataset-v1"]  # Only processes resources named "dataset-v1"
script = "process < $INPUT_FILE > $OUTPUT_DIR/output"
```

## Step Versioning & Change Detection

When you modify a step's script in your manifest, GRIT automatically handles versioning:

1. **Version Creation**: When a step's script or inputs change, a new version is created in the database
2. **Tainted Steps**: Database method `GetTaintedSteps()` identifies steps with newer definitions
3. **Historical Preservation**: Old tasks remain in the database as historical records
4. **Automatic Handling**: Simply re-run the pipeline - new tasks will use the new version

### Workflow
```bash
# Initial run
./grit -manifest workflow.toml --db ./db -run

# Edit workflow.toml - change a step's script or inputs

# Run again - new version is automatically created and used
./grit -manifest workflow.toml --db ./db -run
```

The unique constraint on `(step.name, step.version)` ensures each modification creates a new version while preserving old task executions.

## Database Schema

### SQLite Tables

- **step**: Step definitions and versions
  - `id`: Auto-increment primary key
  - `name`: Step name
  - `script`: Shell script to execute
  - `version`: Auto-incrementing version when script or inputs change
  - `parallel`: Maximum parallel execution limit (0 = unlimited)
  - `inputs`: Filter for which resource names this step processes (NULL or empty means this is a starter step)
  - **Unique constraint**: `(name, version)`

- **task**: Task execution instances
  - `id`: Auto-increment primary key
  - `step_id`: Foreign key to step table
  - `input_resource_id`: Foreign key to resource table (NULL for seed tasks)
  - `processed`: Boolean flag (0 = pending, 1 = completed)
  - `error`: Error message if task failed (NULL if successful)
  - **Unique constraint**: `(step_id, input_resource_id)`

- **resource**: Resource metadata
  - `id`: Auto-increment primary key
  - `name`: Resource identifier (e.g., "dataset-v1", "results")
  - `object_hash`: SHA-256 hash of content stored in BadgerDB
  - `created_at`: Timestamp when resource was created
  - **Unique constraint**: `(name, object_hash)`

### BadgerDB Store

- Key-value store for immutable resource content
- Keys: SHA-256 hashes (hex encoded)
- Values: Raw binary content of resources
- Optimized for batch operations and write-heavy workloads

### Indexes

- `idx_step_name`: Fast step lookup by name
- `idx_task_step`: Efficient task filtering by step
- `idx_task_processed`: Quick filtering of unprocessed tasks
- `idx_resource_name`: Fast resource lookup by name

## Features

- **Dual-Database Architecture**: SQLite for metadata, BadgerDB for content-addressable object storage
- **Resource-Based Flow**: Tasks process resources (named outputs from previous steps)
- **Incremental Processing**: Only creates tasks for unconsumed resources (avoids redundant work)
- **Write-Only FUSE**: Scripts write outputs to FUSE filesystem, ensuring isolation
- **Concurrent Processing**: Configurable parallel task execution with worker pools
- **Persistent State**: Maintains execution history in SQLite, immutable objects in BadgerDB
- **Step Versioning**: Automatically tracks script and input changes
- **Content Deduplication**: SHA-256 hashing prevents storing duplicate objects
- **Seed Tasks**: Start steps execute with NULL input to initialize pipelines
- **Step Filtering**: Run specific subset of steps via `-step` flag
- **Batch Operations**: Efficient batch read/write to BadgerDB
- **Graceful Shutdown**: FUSE filesystems unmount cleanly with timeout + force-flush
- **Shell Script Flexibility**: Execute any shell command or script
- **Export Functionality**: Extract resources by name or hash for external use
- **Disk Space Monitoring**: Warns when disk usage exceeds 85%
- **Flexible Logging**: Three levels (Quiet, Normal, Verbose) with color-coded output

## Dependencies

- `github.com/danhab99/idk/chans`: Unbounded channel utilities for stream merging
- `github.com/danhab99/idk/workers`: Worker pool for parallel processing
- `github.com/pelletier/go-toml`: TOML parsing for manifest files
- `github.com/fatih/color`: Terminal color output
- `github.com/schollz/progressbar/v3`: Progress bar visualization
- `github.com/mattn/go-sqlite3`: SQLite database driver
- `github.com/dgraph-io/badger/v4`: BadgerDB key-value store
- `github.com/hanwen/go-fuse/v2`: FUSE filesystem implementation
- `github.com/fsnotify/fsnotify`: File system event notifications
- `github.com/alecthomas/chroma`: Syntax highlighting for output
- Standard Go libraries (`database/sql`, `crypto/sha256`, `os/exec`, etc.)

## Example Workflow

1. Create a manifest file `workflow.toml`:
```toml
[[step]]
name = "fetch"
# No inputs specified - this is a starter step
script = """
echo 'sample data' > $OUTPUT_DIR/raw-data
echo 'more samples' > $OUTPUT_DIR/raw-data-2
"""

[[step]]
name = "process"
inputs = ["raw-data"]  # Only process resources named "raw-data"
script = """
tr '[:lower:]' '[:upper:]' < $INPUT_FILE > $OUTPUT_DIR/processed
"""

[[step]]
name = "finalize"
inputs = ["processed"]  # Only process resources named "processed"
script = """
cat $INPUT_FILE | sort > $OUTPUT_DIR/final
"""
```

2. Run the pipeline:
```bash
./grit -manifest workflow.toml -db ./my-db -run
```

3. Export the final results:
```bash
# List all "final" resource hashes
./grit -manifest workflow.toml -db ./my-db -export final

# Export specific resource by hash
./grit -manifest workflow.toml -db ./my-db -export-hash <hash> > output.txt
```

4. Modify the process step in workflow.toml:
```toml
[[step]]
name = "process"
inputs = ["raw-data"]
script = """
# Added additional processing
tr '[:lower:]' '[:upper:]' < $INPUT_FILE | rev > $OUTPUT_DIR/processed
"""
```

5. Run again - new version is automatically created:
```bash
./grit -manifest workflow.toml -db ./my-db -run
```

## Output

The program provides three logging modes controlled by command-line flags:

### Normal Mode (default)
- Manifest loading and step count
- Database initialization (SQLite + BadgerDB)
- Step execution with colored log prefixes
- Task execution messages (ID, step name, input/output details)
- Resource creation notifications with hashes
- Execution summary with total duration

### Verbose Mode (`-verbose` flag)
Everything in Normal mode plus:
- Step registration details with version info
- Database operation details (task scheduling, resource lookups)
- Input/output file paths and byte counts
- Script commands being executed
- Script stdout/stderr output in real-time
- Individual task processing information
- FUSE mount/unmount operations

### Quiet Mode (`-quiet` flag)
- Only critical errors and failures
- No progress indicators or status updates
- Suitable for CI/CD and automated environments
