# HandwritingApp

A macOS application that converts handwritten text to digital text using SwiftUI and Vision framework.

![Example of handwriting recognition](docs/example.png)

## Features

- Drawing canvas with pressure sensitivity
- Multiple tools:
  - Pencil tool for writing
  - Eraser tool for corrections
  - Lasso tool for selecting text
- Real-time handwriting recognition
- Text recognition results displayed in both UI and terminal

## Prerequisites

- macOS 13.0 or later
- Xcode 14.0 or later
- Swift 5.9 or later
- Python 3.8 or later (for ML model generation)

## Setup

1. Clone this repository:
```bash
git clone https://github.com/yourusername/HandwritingApp.git
cd HandwritingApp
```

2. Generate the TrOCR ML model:

First, clone the TrOCR model repository:
```bash
git clone https://github.com/ajmcclary/trocr-small-handwritten-coreml.git
cd trocr-small-handwritten-coreml
```

Install the required Python dependencies:
```bash
pip install -r requirements.txt
```

Run the conversion script to generate the CoreML model:
```bash
python convert_to_coreml.py
```

This will generate `TrOCR-Handwritten.mlpackage`. Copy this file to the HandwritingApp's Resources directory:
```bash
cp TrOCR-Handwritten.mlpackage /path/to/HandwritingApp/HandwritingApp/Resources/
```

3. Build and run the app:
```bash
swift build
swift run
```

## Usage

1. **Drawing**:
   - Select the pencil tool (default)
   - Draw text on the canvas
   - Use the eraser tool if needed for corrections

2. **Text Recognition**:
   - Select the lasso tool
   - Draw around the text you want to recognize
   - Click the text recognition button (viewfinder icon)
   - View the recognized text in both the UI and terminal

3. **Additional Controls**:
   - Clear selection: X button when selection is active
   - Clear canvas: Trash button
   - Tool selection: Click on tool icons in the toolbar

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture:

- **Models**: Data structures for drawing tools and lines
- **Views**: SwiftUI views for the canvas and UI
- **ViewModels**: Business logic and state management

## Technical Details

- Built with SwiftUI for the user interface
- Uses Core ML and Vision frameworks for text recognition
- Implements custom drawing using SwiftUI Canvas
- Handles pressure sensitivity for better drawing experience
- Uses Vision's VNRecognizeTextRequest for accurate handwriting recognition

## Source Repositories

- HandwritingApp (this repository)
- [TrOCR Model](https://github.com/ajmcclary/trocr-small-handwritten-coreml): Contains the Python scripts for generating the CoreML model

## License

[Your chosen license]

## Acknowledgments

- TrOCR model conversion scripts by [ajmcclary](https://github.com/ajmcclary)
- Original TrOCR model by Microsoft Research
