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
  
  private var screenWidth: CGFloat { UIScreen.main.bounds.width }
  
  // MARK: - Layer Management
  private func isLayerActive() -> Bool {
    layers.contains(where: \.isActive)
  }
  
  private func getActiveLayerIndex() -> Int? {
    layers.firstIndex(where: \.isActive)
  }
  
  private func deleteActiveLayer() {
    guard let index = getActiveLayerIndex() else { return }
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
  
  // MARK: - Canvas Operations
  private func saveCanvas() {
    let canvas = ZStack(alignment: .center) {
      ForEach(Array(layers.enumerated().filter { $0.element.isVisible }).reversed(), id: \.element.id) { index, _ in
        LayerContentView(layer: layers[index])
      }
    }
    .background(.white)
    .frame(width: options.canvasSize.width, height: options.canvasSize.height)
    
    let renderer = ImageRenderer(content: canvas)
    
    if let img = renderer.uiImage {
      UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
      showPopup(message: "Image saved to Photos")
    } else {
      showPopup(message: "Failed to save image")
    }
  }
  
  private func saveProject() {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsDirectory.appendingPathComponent("layers.json")
    
    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      let data = try encoder.encode(layers)
      try data.write(to: fileURL)
      showToastMessage("Project saved")
    } catch {
      showToastMessage("Failed to save project")
    }
  }
  
  private func loadProject() {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsDirectory.appendingPathComponent("layers.json")
    
    do {
      let data = try Data(contentsOf: fileURL)
      layers = try JSONDecoder().decode([Layer].self, from: data)
      showToastMessage("Project loaded")
    } catch {
      showToastMessage("Failed to load project")
    }
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
    Button(action: {
      options.maintainAspectRatio.toggle()
      showToastMessage(options.maintainAspectRatio ? "Aspect Ratio Enabled" : "Aspect Ratio Disabled")
    }) {
      Image(systemName: "square.resize")
        .font(.system(size: iconSize))
    }
    .frame(width: 33)
    .foregroundStyle(options.maintainAspectRatio ? .blue : .gray)
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
        .foregroundStyle(isLayerActive() ? .red : .gray)
        .font(.system(size: iconSize/1.25))
        .padding(.trailing, 8)
    }
    .disabled(!isLayerActive())
    .alert("Are you sure you want to delete the layer? This action is irreversible",
           isPresented: $deleteAlertVisible) {
      Button("Delete", role: .destructive) {
        deleteActiveLayer()
      }
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
