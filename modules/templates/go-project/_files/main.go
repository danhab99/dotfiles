package main

import (
)

func main() {
	if len(os.Args) < 2 {
		printUsage()
		os.Exit(1)
	}

	command := os.Args[1]

	switch command {
	// case "run":
	// 	runCmd := flag.NewFlagSet("run", flag.ExitOnError)
	// 	run.RegisterFlags(runCmd)
	// 	runCmd.Parse(os.Args[2:])
	// 	run.Execute()

	case "help", "-h", "--help":
		printUsage()

	default:
		fmt.Fprintf(os.Stderr, "Unknown command: %s\n\n", command)
		printUsage()
		os.Exit(1)
	}
}

func printUsage() {
}
