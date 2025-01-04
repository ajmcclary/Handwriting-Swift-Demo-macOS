import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DrawingViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 16) {
                // Drawing tools
                ForEach(DrawingTool.allCases, id: \.self) { tool in
                    Button {
                        viewModel.selectedTool = tool
                        if tool != .lasso {
                            viewModel.clearSelection()
                        }
                    } label: {
                        Image(systemName: tool.systemImageName)
                            .font(.title2)
                    }
                    .buttonStyle(.bordered)
                    .tint(viewModel.selectedTool == tool ? .accentColor : .secondary)
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
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.isProcessing)
                    
                    Button {
                        viewModel.clearSelection()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .font(.title2)
                    }
                    .buttonStyle(.bordered)
                }
                
                Button {
                    viewModel.clearCanvas()
                } label: {
                    Image(systemName: "trash")
                        .font(.title2)
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            // Drawing Canvas
            DrawingCanvasView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            
            // Recognition Results
            if let recognizedText = viewModel.recognizedText {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recognized Text:")
                        .font(.headline)
                    Text(recognizedText)
                        .textSelection(.enabled)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
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
                }
            }
        )
        .overlay(
            Group {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                        .padding()
                }
            }
        )
    }
}

#Preview {
    ContentView()
}
