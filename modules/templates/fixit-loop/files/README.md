# Fix It Loop

An automated fix loop that uses opencode to iteratively fix problems until tests pass.

## How It Works

1. You define a set of test commands that should pass when the problem is solved.
2. The script runs those commands.
3. If they pass, the loop exits successfully.
4. If they fail, the error output is sent to opencode in CLI mode with auto-approval enabled, instructing it to fix the problem.
5. The loop repeats until the tests pass or the maximum number of iterations is reached.

## Usage

1. Open the `fix_it_loop` script and fill in the `TEST_COMMANDS` heredoc with your test commands:

   ```bash
   read -r -d '' TEST_COMMANDS << 'TESTS' || true
     nix build .#my-package
     my-test-suite --run
   TESTS
   ```

2. Make the script executable and run it:

   ```bash
   chmod +x fix_it_loop
   ./fix_it_loop
   ```

## Configuration

- **`MAX_ITERATIONS`** — Maximum number of fix attempts before giving up (default: 10).
- **`TEST_COMMANDS`** — The commands to run. All must exit with code 0 for the loop to stop.

## Requirements

- [opencode](https://opencode.ai) installed and configured with an LLM provider.
