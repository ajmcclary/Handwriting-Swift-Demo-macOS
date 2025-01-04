import SwiftUI

/// The main view of the application that coordinates the drawing interface
///
/// ContentView serves as the container for the drawing canvas and toolbar,
/// managing the overall layout and user interface of the application.
/// It handles initialization failures gracefully by displaying an error view
/// when text recognition services are unavailable.
///
/// Key responsibilities:
/// - Managing the drawing toolbar and tool selection
/// - Displaying the drawing canvas
/// - Showing text recognition results
/// - Handling error states and user feedback
struct ContentView: View {
    /// View model that manages the drawing state and business logic
    @StateObject private var viewModel: DrawingViewModel
    
    /// Initialization error if view model creation fails
    @State private var initializationError: HandwritingError?
    
    /// Creates a new instance of ContentView
    /// - Note: If initialization of the DrawingViewModel fails due to unavailable
    ///         text recognition services, it will fall back to preview mode and
    ///         display an error message to the user.
    init() {
        let viewModel: DrawingViewModel
        do {
            viewModel = try DrawingViewModel()
        } catch let error as HandwritingError {
            viewModel = DrawingViewModel.preview()
            self.initializationError = error
        } catch {
            viewModel = DrawingViewModel.preview()
            self.initializationError = .textRecognitionFailed(error)
        }
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            if let error = initializationError {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                    
                    Text("Initialization Error")
                        .font(.title)
                        .foregroundColor(.red)
                    
                    VStack(spacing: 8) {
                        Text(error.errorDescription ?? "Unknown error")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        if let recovery = error.recoverySuggestion {
                            Text(recovery)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        if let helpAnchor = error.helpAnchor {
                            Link("Learn More", destination: URL(string: "help://\(helpAnchor)")!)
                                .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(Color(NSColor.windowBackgroundColor))
            } else {
                VStack(spacing: 0) {
                    // Toolbar with drawing tools and actions
                    HStack(spacing: 16) {
                        // Drawing tool selection buttons
                        ForEach(DrawingTool.allCases, id: \.self) { tool in
                            Button {
                                viewModel.selectedTool = tool
                                if tool != .lasso {
                                    viewModel.clearSelection()
                                }
                            } label: {
                                Image(systemName: tool.systemImageName)
                                    .font(.title2)
                                    .accessibilityLabel(tool.rawValue.capitalized)
                            }
                            .buttonStyle(.bordered)
                            .tint(viewModel.selectedTool == tool ? .accentColor : .secondary)
                            .accessibilityIdentifier("tool.\(tool.rawValue)")
                        }
                        
                        Divider()
                            .frame(height: 20)
                        
                        // Action buttons
                        if viewModel.selectedArea != nil {
                            Button {
                                Task {
                                    await viewModel.processSelectedArea()
                                }
                            } label: {
                                Image(systemName: "text.viewfinder")
                                    .font(.title2)
                                    .accessibilityLabel("Recognize Text")
                            }
                            .buttonStyle(.bordered)
                            .disabled(viewModel.isProcessing)
                            .accessibilityIdentifier("button.recognizeText")
                            
                            Button {
                                viewModel.clearSelection()
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .font(.title2)
                                    .accessibilityLabel("Clear Selection")
                            }
                            .buttonStyle(.bordered)
                            .accessibilityIdentifier("button.clearSelection")
                        }
                        
                        Button {
                            viewModel.clearCanvas()
                        } label: {
                            Image(systemName: "trash")
                                .font(.title2)
                                .accessibilityLabel("Clear Canvas")
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("button.clearCanvas")
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(NSColor.windowBackgroundColor))
                    
                    // Main drawing canvas
                    DrawingCanvasView(viewModel: viewModel)
                        .accessibilityIdentifier("canvas.drawing")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                    
                    // Text recognition results panel
                    if let recognizedText = viewModel.recognizedText {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recognized Text:")
                                .font(.headline)
                                .accessibilityAddTraits(.isHeader)
                            Text(recognizedText)
                                .textSelection(.enabled)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(NSColor.textBackgroundColor))
                                .cornerRadius(8)
                                .accessibilityIdentifier("text.recognitionResult")
                        }
                        .padding()
                        .background(Color(NSColor.windowBackgroundColor))
                        .transition(.move(edge: .bottom))
                    }
                }
                .frame(minWidth: 800, minHeight: 600)
                .overlay(
                    Group {
                        if viewModel.isProcessing {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaleEffect(1.5)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black.opacity(0.2))
                                .accessibilityIdentifier("progress.processing")
                                .accessibilityLabel("Processing handwriting")
                        }
                    }
                )
                .overlay(
                    Group {
                        if let error = viewModel.errorMessage {
                            VStack(spacing: 8) {
                                Text(error)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding()
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(12)
                            .padding()
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
