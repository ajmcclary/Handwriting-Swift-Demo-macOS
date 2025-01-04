#!/bin/bash

# Check if xcrun is available
if ! command -v xcrun &> /dev/null; then
    echo "xcrun could not be found. Please ensure Xcode is installed."
    exit 1
fi

# Compile the model
echo "Compiling ML model..."
xcrun coremlc compile HandwritingApp/Resources/TrOCR-Handwritten.mlpackage HandwritingApp/Resources/

echo "Converting model to Swift..."
xcrun coremlc generate HandwritingApp/Resources/TrOCR-Handwritten.mlpackage HandwritingApp/Resources/

chmod -R 755 HandwritingApp/Resources/TrOCR-Handwritten.mlpackage
