import SwiftUI

struct TopMenuView: View {
  @Binding var layers: [Layer]
  @Binding var isSidebarVisible: Bool
  @EnvironmentObject var options: OptionsModel
  @State private var showToast = false
  @State private var toastMessage = "..."
  @State var deleteAlertVisible:Bool = false
  
  var screenWidth: CGFloat { UIScreen.main.bounds.width }
  
  func isLayerActive() -> Bool {
    return layers.contains(where: \.isActive)
  }
  
  func getActiveLayerIndex() -> Int? {
    return layers.firstIndex(where: \.isActive)
  }
  
  func deleteActiveLayer() {
    guard let index = getActiveLayerIndex() else { return }
    print("deleted layer", index)
    layers.remove(at: index)
    showToastMessage("Layer deleted")
  }
  
  func showToastMessage(_ message: String) {
    toastMessage = message
    showToast = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      withAnimation {
        showToast = false
      }
    }
  }
  
  func saveCanvas() {
    print("Trying to save canvas")
    
    // Define a higher resolution for the canvas
    let targetSize = CGSize(width: 2000, height: 2000)
    let scale = targetSize.width / screenWidth
    // Create the high-resolution canvas
    let canvas = ZStack(alignment: .center) {
      ForEach(
        Array(layers.enumerated().filter { $0.element.isVisible }).reversed(),
        id: \.element.id
      ) { index, _ in
        LayerContentView(layer: layers[index])
          .scaleEffect(scale, anchor: UnitPoint(x: 0, y: 0))
      }
    }
      .background(.white)
      .frame(width: targetSize.width, height: targetSize.height)
    
    // Render the high-resolution canvas
    let renderer = ImageRenderer(content: canvas)
    renderer.scale = UIScreen.main.scale
    
    // Save the rendered image
    if let img = renderer.uiImage {
      UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
      showPopup(message: "Image saved to Photos")
    } else {
      showPopup(message: "Failed to save image")
    }
  }
  
  func showPopup(message: String) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
      return
    }
    
    let alert = UIAlertController(
      title: nil,
      message: message,
      preferredStyle: .alert
    )
    rootViewController.present(alert, animated: true)
    
    DispatchQueue.main.asyncAfter(deadline: .now()+1) {
      alert.dismiss(animated: true)
    }
  }
  
  var body: some View {
    ZStack() {
      VStack(spacing: 0) {
        HStack {
          Button(action: {
            isSidebarVisible.toggle()
          }) {
            Label("Layers", systemImage: "square.3.layers.3d.top.filled")
              .font(.system(size: iconSize/1.2))
          }
          
          Spacer()
          
          Button(action: saveCanvas){
            Image(systemName: "square.and.arrow.up")
          }
          .font(.system(size: iconSize/1.1))
          
          Menu {
            Button("Open Project", systemImage: "iphone.and.arrow.right.outward"){
              showToastMessage("TODO")
            }
            Button("Save Project", systemImage: "iphone.and.arrow.right.inward"){
//              print(layers)
//              print(JSONEncoder().encode(layers))
              showToastMessage("TODO")
            }
            Divider()
            Link("Follow on X (Twitter)", destination: URL(string:"https://twitter.com/PowerEditor_")!)
            Link("Star Github Repo", destination: URL(string: "https://github.com/ankushKun/power-editor")!)
            Link("App Store Listing", destination: URL(string: "https://apps.apple.com/us/app/power-editor/id6739633465?platform=iphone")!)
            Divider()
            Text("Built with ♥️")

          }label:{
            Image(systemName: "ellipsis.circle")
          }.font(.system(size: iconSize/1.1)).padding(.top,5).padding(.horizontal,5)
        }
        .frame(height: 40)
        .padding(5)
        .background(.black)
        
        HStack{
          ScrollView(.horizontal, showsIndicators: false) {
            HStack {
              Button(action: {
                options.maintainAspectRatio.toggle()
                if (options.maintainAspectRatio){
                  showToastMessage("Aspect Ratio Enabled")
                }else {
                  showToastMessage("Aspect Ratio Disabled")
                }
              }) {
                Image(systemName: "square.resize")
                  .font(.system(size: iconSize))
              }
              .frame(width: 33)
              .foregroundStyle(options.maintainAspectRatio ? .blue : .gray)
              
              Rectangle()
                .foregroundStyle(.blue)
                .frame(width: 1)
                .padding(.leading, 1)
                .padding(.trailing, 1)
              
              ForEach(Tool.allCases, id: \.self) { tool in
                Button(action: {
                  options.activeTool = tool
                }) {
                  Image(systemName: tool.icon)
                    .font(.system(size: iconSize))
                }
                .frame(width: 33)
                .background(options.activeTool == tool ? .blue : .clear)
                .foregroundStyle(options.activeTool == tool ? .black : .blue)
                .cornerRadius(5)
              }
            }
            .frame(height: 40).frame(maxWidth: .infinity)
            .padding(5)
          }
          
          
          Button(action:{deleteAlertVisible = true}) {
            Image(systemName: "trash")
              .foregroundStyle(isLayerActive() ? .red : .gray)
              .font(.system(size: iconSize/1.25))
              .padding(.trailing,8)
          }.disabled(!isLayerActive())
            .alert("Are you sure you want to delete the layer? This action is irreversible", isPresented: $deleteAlertVisible){
              Button("Delete", role:.destructive) {
                deleteActiveLayer()
              }
            }
          
        } .background(.black)
        
      }
      if showToast {
        ToastView(message: toastMessage)
          .transition(.opacity)
          .animation(.easeInOut, value: showToast)
      }
    }
  }
}
