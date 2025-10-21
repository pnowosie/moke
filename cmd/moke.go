package main

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

// Version components of the application
// These can be overridden at build time using -ldflags
var (
	Semver = "0.0.0"
	Date   = "2020-01-01"
	Hash   = "0000000"
)

// Version of the application in the required format
var Version = fmt.Sprintf("%s-%s-%s", Semver, Date, Hash)

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "moke",
	Short: "Moke is a mnemonic joke - a mnemonic playground for BIP-39",
	Long: `Moke is the ultimate mnemonic playground! Ever wondered what it's like to juggle words and create magical phrases? 
Well, Moke is here to tickle your brain cells and make you giggle while you play with BIP-39 mnemonics.`,
	Version: Version,
}

func init() {
	// Add version flags
	rootCmd.Flags().BoolP("version", "v", false, "Print the version number and exit")
}

func main() {
	// Check if version flag is set
	if len(os.Args) > 1 && (os.Args[1] == "--version" || os.Args[1] == "-v") {
		fmt.Printf("moke %s\n", Version)
		os.Exit(0)
	}

	// Execute the root command
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}