# HandwritingApp
## Using the Apple's Vision Framework for macOS

A native macOS SwiftUI application that provides real-time handwriting recognition using Apple's Vision framework. Transform your handwritten text into digital format instantly through an intuitive drawing interface.

![HandwritingApp Screenshot](docs/example.png)

## Key Features

### Drawing Tools
* Pressure-sensitive pencil tool that delivers a natural handwriting experience
* Precise eraser tool for quick corrections and touch-ups
* Lasso tool for accurate text area selection and manipulation

### Text Recognition
* Powered by Apple's Vision framework for accurate handwriting recognition
* Real-time processing with immediate feedback
* Comprehensive English text support
* Robust error handling with actionable recovery suggestions

### User Interface
* Minimalist, intuitive toolbar design
* Responsive drawing preview
* Clear visual feedback for selections
* Full accessibility support
* Informative error messaging system

## System Requirements

* macOS 13.0 or later
* Xcode 15.0 or later
* Swift 5.9 or later

## Getting Started

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/ajmcclary/Handwriting-Swift-Demo-macOS.git
   cd Handwriting-Swift-Demo-macOS
   ```

2. Build and run:
   ```bash
   swift run
   ```

### Basic Usage

#### Drawing
* Select the pencil tool from the toolbar
* Draw naturally using your mouse or trackpad
* Experience pressure sensitivity with compatible hardware

#### Erasing
* Switch to the eraser tool
* Click and drag to remove unwanted content

#### Text Recognition
1. Select the lasso tool
2. Draw around text you want to digitize
3. Click the "Recognize Text" button (viewfinder icon)
4. View results in the dedicated panel

#### Content Management
* Clear selection: Click the X icon
* Reset canvas: Click the trash icon

## Technical Details

### Architecture

The application implements the MVVM (Model-View-ViewModel) pattern:

#### Models
* `DrawingTool`: Drawing tool enumeration
* `DrawingPoint`: Point representation
* `DrawingLine`: Line representation
* `LassoSelection`: Selection management
* `HandwritingError`: Error handling

#### Views
* `ContentView`: Primary container
* `DrawingCanvasView`: Drawing and selection renderer

#### ViewModels
* `DrawingViewModel`: State and logic manager

#### Services
* `TextRecognitionService`: Vision framework integration

### Testing

Run the test suite:
```bash
swift test
```

Coverage includes:
* Drawing functionality
* Tool selection logic
* Error handling scenarios
* Text recognition accuracy
* Performance benchmarks

### Error Handling

The application provides comprehensive error management:
* Detailed error messages
* Recovery suggestions
* Common issue resolution paths

### Accessibility Features

* Complete VoiceOver navigation support
* Intuitive keyboard shortcuts
* High contrast visual options
* Descriptive accessibility labels and hints

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/YourFeature`
3. Commit changes: `git commit -m 'Add YourFeature'`
4. Push to branch: `git push origin feature/YourFeature`
5. Submit a Pull Request

## License

Released under the MIT License. See the [LICENSE](LICENSE) file for details.