# TestApp - TrustPinKit Example

This is a sample iOS app demonstrating how to use TrustPinKit in a SwiftUI application.

## Prerequisites

This TestApp uses [Tuist](https://tuist.io) for project generation. Install Tuist first:

```bash
# Install Tuist
curl -Ls https://install.tuist.io | bash

# Or using Homebrew
brew install tuist
```

## Running the Example

### Using Tuist (Recommended)

1. **Navigate to the TestApp directory**:
   ```bash
   cd TestApp
   ```

2. **Generate the Xcode project**:
   ```bash
   tuist generate
   ```

3. **Open the generated project**:
   ```bash
   tuist generate --open
   ```

4. **Run the app** on simulator or device using Xcode

### Alternative: Manual Xcode Setup

If you prefer not to use Tuist:

1. **Create a new iOS App project in Xcode**
2. **Add TrustPinKit as a dependency**:
   - File → Add Package Dependencies
   - Enter: `https://github.com/trustpin-cloud/TrustPin-Swift`
3. **Copy the source files** from `Sources/` to your project
4. **Run the app**

## Integration Example

The TestApp shows how to:

1. **Setup TrustPinKit** in your app
2. **Configure certificate pinning** for your API endpoints  
3. **Handle URLSession** with automatic certificate validation
4. **Implement proper error handling** for pinning failures

## Code Structure

- `Sources/TestApp.swift` - Main app entry point and TrustPin setup
- `Sources/ContentView.swift` - SwiftUI view with network request examples
- `Sources/Assets.xcassets` - App icons and colors
- `Sources/LaunchScreen.storyboard` - Launch screen
- `Sources/TestApp.entitlements` - App entitlements
- `Project.swift` - Tuist project configuration
- `Tuist.swift` - Tuist configuration

## Key Features Demonstrated

- ✅ TrustPin initialization with organization credentials
- ✅ URLSession integration with TrustPinURLSessionDelegate
- ✅ Error handling for certificate pinning failures
- ✅ Network request examples with automatic validation
- ✅ SwiftUI integration patterns
- ✅ Proper iOS app structure with Tuist

## Development

### Installing Tuist

Install Tuist to manage the project dependencies and generate Xcode projects:

```bash
# Install Tuist
curl -Ls https://install.tuist.io | bash

# Or using Homebrew
brew install tuist
```

For more information, visit: [tuist.io](https://tuist.io)

### Creating the Xcode Project

Once Tuist is installed, generate the Xcode project:

```bash
# Clean generated files
tuist clean

# Install dependencies
tuist install

# Generate Xcode project
tuist generate
```

## Learn More

- [Tuist Documentation](https://docs.tuist.io)
- [TrustPinKit Documentation](../README.md)