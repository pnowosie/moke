# moke

Moke is a mnemonic joke

## Overview

Welcome to Moke, the ultimate mnemonic playground! Ever wondered what it's like to juggle words and create magical phrases? Well, Moke is here to tickle your brain cells and make you giggle while you play with BIP-39 mnemonics.

## Features

Moke offers several features to help users understand and play with BIP-39 mnemonics:

- **Checksum Verification**: Moke can verify if a given mnemonic has the correct checksum. This ensures that the mnemonic is valid according to the BIP-39 standard.
- **Mnemonic Completion**: If you have a partial mnemonic, Moke can help you complete it by suggesting possible words that fit the checksum requirement.
- **Checksum Word Listing**: Moke can list all valid words that can be used to complete a mnemonic with a correct checksum. This is useful for educational purposes and for understanding how mnemonics are constructed.

## Security Disclaimer

Please note that Moke is not designed with security in mind. It is intended purely for educational and entertainment purposes. Do not use Moke for generating or managing any sensitive applications.

## Quick Start

### Installation Methods

#### Option 1: Go Install (if Go is installed)

If you have Go installed on your system, the easiest way to install moke is:

```bash
go install github.com/pnowosie/moke@latest
```

This will download and install the latest version of moke to your `$GOPATH/bin` directory.

#### Option 2: Download Pre-built Binaries

##### Quick Install (curl | bash)

The easiest way to install moke is using our automated installer:

```bash
# Download and install directly from GitHub
curl -fsSL https://raw.githubusercontent.com/pnowosie/moke/main/scripts/install.sh | bash -s -- --install

# Or just download the binary locally
curl -fsSL https://raw.githubusercontent.com/pnowosie/moke/main/scripts/install.sh | bash -s -- --download
```

The installer automatically:

- Detects your OS and architecture
- Downloads the correct binary from the latest release
- Validates checksums for security
- Installs to `/usr/local/bin` (with `--install` flag)

##### Manual Download

In case you don't trust the installation script, manual download of a pre-built binary from the [Releases](https://github.com/pnowosie/moke/releases) page is still an option.

#### Option 3: Build from Source

If you prefer to build from source or want to contribute:

1. **Prerequisites**:
   - Go 1.23.4 or later
   - Git

2. **Clone and build**:
   ```bash
   git clone https://github.com/pnowosie/moke
   cd moke
   ./scripts/build.sh --platform local
   ```

3. **Or use the build script**:
   ```bash
   ./scripts/build.sh --help
   ./scripts/build.sh --platform local
   ```

## Development Workflow

### Building for Different Platforms

Use the enhanced build script to build for specific platforms:

```bash
# Build for local platform
./scripts/build.sh

# Build for specific platforms
./scripts/build.sh --platform linux-amd64
./scripts/build.sh --platform linux-arm64
./scripts/build.sh --platform darwin-amd64
./scripts/build.sh --platform darwin-arm64

# Override version
./scripts/build.sh --platform linux-amd64 --version 1.0.0
```

### Creating Releases

1. **Create a release**:

   ```bash
   ./scripts/release.sh create 1.0.0
   ```

2. **List existing tags**:

   ```bash
   ./scripts/release.sh list
   ```

3. **Monitor the release process**:
   - The script will automatically trigger GitHub Actions
   - Check the [Actions tab](https://github.com/pnowosie/moke/actions) for build progress
   - Once complete, binaries will be available in the [Releases](https://github.com/pnowosie/moke/releases) page

## Automated Builds

This project uses GitHub Actions for automated building and releasing:

- **On PR merge**: Builds binaries for all platforms and uploads them as artifacts
- **On version tag**: Creates a GitHub release with downloadable binaries
- **Supported platforms**: Linux (amd64, arm64) and macOS (amd64, arm64)

### Workflow Triggers

- **Build & Test**: Runs on every push to `main` and on pull requests
- **Build on Merge**: Builds binaries when PRs are merged to `main`
- **Release**: Creates releases when version tags (e.g., `v1.0.0`) are pushed

## Contributing

We welcome contributions from the community! Here's how to get started:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Make** your changes and test them
4. **Commit** your changes: `git commit -m 'Add amazing feature'`
5. **Push** to the branch: `git push origin feature/amazing-feature`
6. **Open** a Pull Request

### Development Guidelines

- Follow Go best practices and conventions
- Add tests for new features
- Update documentation as needed
- Ensure all workflows pass before submitting PRs

## License

No licence - use it or ignore it, however you like.
