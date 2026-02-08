package main

import (
	"flag"
	"fmt"
	"os"

	"grit/cmd/export"
	"grit/cmd/run"
	"grit/cmd/status"
)

func main() {
	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}

	command := os.Args[1]

	switch command {
	case "run":
		runCmd := flag.NewFlagSet("run", flag.ExitOnError)
		run.RegisterFlags(runCmd)
		runCmd.Parse(os.Args[2:])
		run.Execute()

	case "export":
		exportCmd := flag.NewFlagSet("export", flag.ExitOnError)
		export.RegisterFlags(exportCmd)
		exportCmd.Parse(os.Args[2:])
		export.Execute()

	case "status":
		statusCmd := flag.NewFlagSet("status", flag.ExitOnError)
		status.RegisterFlags(statusCmd)
		statusCmd.Parse(os.Args[2:])
		status.Execute()

	case "help", "-h", "--help":
		printUsage()

	default:
		fmt.Fprintf(os.Stderr, "Unknown command: %s\n\n", command)
		printUsage()
		os.Exit(1)
	}
}

func printUsage() {
	fmt.Println("grit - Task pipeline management system")
	fmt.Println("\nUsage:")
	fmt.Println("  grit <command> [flags]")
	fmt.Println("\nAvailable commands:")
	fmt.Println("  run       Run the pipeline")
	fmt.Println("  export    Export resources from the database")
	fmt.Println("  status    Show pipeline status and statistics")
	fmt.Println("\nUse 'grit <command> -h' for more information about a command.")
}
