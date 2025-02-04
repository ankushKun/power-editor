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
        LayerContentView(layer: layers[index])
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
          .transition(.opacity)
          .animation(.easeInOut, value: showToast)
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
    .frame(height: 40)
    .padding(5)
    .background(.black)
  }
  
  private var layersButton: some View {
    Button(action: { isSidebarVisible.toggle() }) {
      Label("Layers", systemImage: "square.3.layers.3d.top.filled")
        .font(.system(size: iconSize/1.2))
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
    }
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
    }
    .padding(.top, 5)
    .padding(.horizontal, 5)
  }
  
  private var toolBar: some View {
    HStack {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack {
          aspectRatioButton
          Divider()
          toolButtons
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .padding(5)
      }
      
      deleteButton
    }
    .background(.black)
  }
  
  private var aspectRatioButton: some View {
    Button(action: toggleAspectRatio) {
      Image(systemName: "square.resize")
        .font(.system(size: iconSize))
    }
    .frame(width: 33)
    .foregroundStyle(options.maintainAspectRatio ? .blue : .gray)
  }
  
  private func toggleAspectRatio() {
    options.maintainAspectRatio.toggle()
    showToastMessage(options.maintainAspectRatio ? "Aspect Ratio Enabled" : "Aspect Ratio Disabled")
  }
  
  private var toolButtons: some View {
    ForEach(Tool.allCases, id: \.self) { tool in
      Button(action: { options.activeTool = tool }) {
        Image(systemName: tool.icon)
          .font(.system(size: iconSize))
      }
      .frame(width: 33)
      .background(options.activeTool == tool ? .blue : .clear)
      .foregroundStyle(options.activeTool == tool ? .black : .blue)
      .cornerRadius(5)
    }
  }
  
  private var deleteButton: some View {
    Button(action: { deleteAlertVisible = true }) {
      Image(systemName: "trash")
        .foregroundStyle(hasActiveLayer ? .red : .gray)
        .font(.system(size: iconSize/1.25))
        .padding(.trailing, 8)
    }
    .disabled(!hasActiveLayer)
    .alert("Are you sure you want to delete the layer? This action is irreversible",
           isPresented: $deleteAlertVisible) {
      Button("Delete", role: .destructive, action: deleteActiveLayer)
    }
  }
  
  private var projectButtons: some View {
    Group {
      Button("Open Project", systemImage: "iphone.and.arrow.right.outward", action: loadProject)
      Button("Save Project", systemImage: "iphone.and.arrow.right.inward", action: saveProject)
    }
  }
  
  private var socialLinks: some View {
    Group {
      Link("Follow on X (Twitter)", 
           destination: URL(string: "https://twitter.com/PowerEditor_")!)
      Link("Star Github Repo",
           destination: URL(string: "https://github.com/ankushKun/power-editor")!)
      Link("App Store Listing",
           destination: URL(string: "https://apps.apple.com/us/app/power-editor/id6739633465?platform=iphone")!)
    }
  }
}
