import SwiftUI

struct TopMenuView: View {
  // MARK: - Properties
  @Binding var layers: [Layer]
  @Binding var isSidebarVisible: Bool
  @EnvironmentObject var options: OptionsModel
  
  @State private var showToast = false
  @State private var toastMessage = "..."
  @State private var deleteAlertVisible = false
  @State private var showExportOptions = false
  
  // MARK: - Layer Management
  private var activeLayerIndex: Int? {
    layers.firstIndex(where: \.isActive)
  }
  
  private var hasActiveLayer: Bool {
    layers.contains(where: \.isActive)
  }
  
  private func deleteActiveLayer() {
    guard let index = activeLayerIndex else { return }
    layers.remove(at: index)
    showToastMessage("Layer deleted")
  }
  
  // MARK: - UI Feedback
  private func showToastMessage(_ message: String) {
    toastMessage = message
    withAnimation {
      showToast = true
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      withAnimation {
        showToast = false
      }
    }
  }
  
  private func showPopup(message: String) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
      return
    }
    
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    rootViewController.present(alert, animated: true)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      alert.dismiss(animated: true)
    }
  }
  
  // MARK: - File Operations
  private func saveCanvas() {
    let canvas = ZStack(alignment: .center) {
      ForEach(layers.enumerated().filter { $0.element.isVisible }.reversed(), id: \.element.id) { index, _ in
        LayerContentView(layer: layers[index], export: true)
          .environmentObject(options)
      }
    }
    .background(.white)
    .frame(width: options.canvasSize.width, height: options.canvasSize.height)
    
    if let image = ImageRenderer(content: canvas).uiImage {
      UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
      showPopup(message: "Image saved to Photos")
    } else {
      showPopup(message: "Failed to save image")
    }
  }
  
  private func handleProjectOperation(_ operation: () throws -> Void, successMessage: String, failureMessage: String) {
    do {
      try operation()
      showToastMessage(successMessage)
    } catch {
      showToastMessage(failureMessage)
    }
  }
  
  private func saveProject() {
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("layers.json")
    
    handleProjectOperation({
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      try encoder.encode(layers).write(to: fileURL)
    }, successMessage: "Project saved", failureMessage: "Failed to save project")
  }
  
  private func loadProject() {
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("layers.json")
    
    handleProjectOperation({
      layers = try JSONDecoder().decode([Layer].self, from: try Data(contentsOf: fileURL))
    }, successMessage: "Project loaded", failureMessage: "Failed to load project")
  }
  
  // MARK: - View
  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        topBar
        toolBar
      }
      
      if showToast {
        ToastView(message: toastMessage)
          .transition(.moveAndFade)
          .animation(.spring(), value: showToast)
      }
    }
    .sheet(isPresented: $showExportOptions) {
      ExportOptionsView(options: options)
    }
  }
  
  // MARK: - Subviews
  private var topBar: some View {
    HStack {
      layersButton
      Spacer()
      exportMenu
      moreMenu
    }
    .frame(height: 44)
    .padding(.horizontal, 8)
    .background(.black)
    .foregroundStyle(.blue)
  }
  
  private var layersButton: some View {
    Button(action: { isSidebarVisible.toggle() }) {
      HStack {
        Image(systemName: "square.3.layers.3d.top.filled")
          .font(.system(size: iconSize/1.2))
        Text("Layers")
          .font(.system(size: 17, weight: .medium))
      }
      .foregroundStyle(.blue)
    }
  }
  
  private var exportMenu: some View {
    Menu {
      Button(action: { showExportOptions = true }) {
        Label("Export Settings", systemImage: "gear")
      }
      Button(action: saveCanvas) {
        Label("Save to Photos", systemImage: "square.and.arrow.up")
      }
    } label: {
      Image(systemName: "square.and.arrow.up")
        .font(.system(size: iconSize/1.1))
        .foregroundStyle(.blue)
    }
    .menuStyle(.borderlessButton)
  }
  
  private var moreMenu: some View {
    Menu {
      projectButtons
      Divider()
      socialLinks
      Divider()
      Text("Built with ♥️")
    } label: {
      Image(systemName: "ellipsis.circle")
        .font(.system(size: iconSize/1.1))
        .foregroundStyle(.blue)
    }
    .padding(.top, 5)
    .padding(.horizontal, 5)
  }
  
  private var toolBar: some View {
    HStack(spacing: 16) {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          aspectRatioButton
          Divider()
            .frame(height: 24)
            .background(.gray.opacity(0.5))
          toolButtons
          Divider()
            .frame(height: 24)
            .background(.gray.opacity(0.5))
          modificationButtons
        }
        .padding(.horizontal, 12)
      }
      
      deleteButton
    }
    .frame(height: 50)
    .background(.black)
  }
  
  private var aspectRatioButton: some View {
    Button(action: toggleAspectRatio) {
      Image(systemName: "square.resize")
        .font(.system(size: 22, weight: .medium))
    }
    .buttonStyle(.plain)
    .foregroundStyle(options.maintainAspectRatio ? .blue : .gray)
  }
  
  private func toggleAspectRatio() {
    options.maintainAspectRatio.toggle()
    showToastMessage(options.maintainAspectRatio ? "Aspect Ratio Locked" : "Aspect Ratio Unlocked")
  }
  
  private var toolButtons: some View {
    HStack(spacing: 5) {
      ForEach(Tool.allCases, id: \.self) { tool in
        Button(action: { options.activeTool = tool }) {
          Image(systemName: tool.icon)
            .font(.system(size: 22, weight: .medium))
            .frame(width: 40, height: 40)
            .background(options.activeTool == tool ? .blue : .clear)
            .foregroundStyle(options.activeTool == tool ? .black : .blue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
      }
    }
  }

  private var modificationButtons: some View {
    HStack(spacing: 5) {
      Button(action: {
        if let activeLayer = activeLayerIndex {
          layers[activeLayer].position.x = options.canvasSize.width / 2 - layers[activeLayer].size.width / 2
        }
      }) {
        Image(systemName: "arrow.right.and.line.vertical.and.arrow.left")
          .font(.system(size: 22, weight: .medium))
          .foregroundStyle(hasActiveLayer ? .blue : .gray.opacity(0.5))
      }
      .disabled(!hasActiveLayer)

      Button(action: {
        if let activeLayer = activeLayerIndex {
          layers[activeLayer].position.y = options.canvasSize.height / 2 - layers[activeLayer].size.height / 2
        }
      }) {
        Image(systemName: "arrow.down.and.line.horizontal.and.arrow.up")
          .font(.system(size: 22, weight: .medium))
          .foregroundStyle(hasActiveLayer ? .blue : .gray.opacity(0.5))
      }
      .disabled(!hasActiveLayer)
    }
  }
  
  private var deleteButton: some View {
    Button(action: { deleteAlertVisible = true }) {
      Image(systemName: "trash")
        .font(.system(size: 20, weight: .medium))
        .foregroundStyle(hasActiveLayer ? .red : .gray.opacity(0.5))
        .frame(width: 44, height: 44)
    }
    .disabled(!hasActiveLayer)
    .alert("Delete Layer", isPresented: $deleteAlertVisible) {
      Button("Cancel", role: .cancel) { }
      Button("Delete", role: .destructive, action: deleteActiveLayer)
    } message: {
      Text("Are you sure you want to delete this layer? This action cannot be undone.")
    }
  }
  
  private var projectButtons: some View {
    Group {
      Button(action: loadProject) {
        Label("Open Project", systemImage: "folder")
          .foregroundStyle(.primary)
      }
      Button(action: saveProject) {
        Label("Save Project", systemImage: "square.and.arrow.down")
          .foregroundStyle(.primary)
      }
    }
  }
  
  private var socialLinks: some View {
    Group {
      Link(destination: URL(string: "https://twitter.com/PowerEditor_")!) {
        Label("Follow on X (Twitter)", systemImage: "bird")
      }
      Link(destination: URL(string: "https://github.com/ankushKun/power-editor")!) {
        Label("Star on GitHub", systemImage: "star")
      }
      Link(destination: URL(string: "https://apps.apple.com/us/app/power-editor/id6739633465?platform=iphone")!) {
        Label("Rate on App Store", systemImage: "star.bubble")
      }
    }
  }
}

extension AnyTransition {
  static var moveAndFade: AnyTransition {
    .asymmetric(
      insertion: .move(edge: .top).combined(with: .opacity),
      removal: .move(edge: .top).combined(with: .opacity)
    )
  }
}
