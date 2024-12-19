//
//  ToolbarView.swift
//  Power Editor
//
//  Created by Ankush Singh on 18/12/24.
//


import SwiftUI
import PhotosUI
let iconSize: CGFloat = 25


struct ToolbarView: View {
  @Binding var layers: [Layer]
  @State var deleteAlertVisible:Bool = false
  @State private var selectedImage: UIImage? = nil
  
  func deleteActiveLayer() {
    guard let index = getActiveLayerIndex() else { return }
    print("deleted layer", index)
    layers.remove(at: index)
  }
  
  func addTextLayer() {
    layers
      .append(
        Layer(
          name: "Text Layer",
          content: .text("Hello World")
        )
      )
  }
  
  func addColorLayer(){
    layers
      .append(
        Layer(
          name: "Color Layer",
          content: .color(.red)
        )
      )
  }
  
  func isLayerActive() -> Bool {
    return layers.contains(where: \.isActive)
  }
  
  func getActiveLayerIndex() -> Int? {
    return layers.firstIndex(where: \.isActive)
  }
  
  var body: some View {
    VStack(spacing: 0){
      ScrollView(.horizontal, showsIndicators: false){
        HStack{
          if isLayerActive() {
            switch layers[getActiveLayerIndex()!].content {
              case .text(let text):
                //                  text input field
                TextField("",text: Binding(get: {
                  text
                }, set: {
                  newValue in
                  //                update the active layer content
                  layers[getActiveLayerIndex()!].content = .text(newValue)
                  print(newValue)
                  
                })).frame(maxHeight: .infinity)
                  .padding(5).background(.white).foregroundStyle(
                    .black
                  ).frame(maxWidth: 150)
              case .color(let color):
                ColorPicker("color", selection: Binding(get: {
                  color
                }, set: {
                  newValue in
                  layers[getActiveLayerIndex()!].content = .color(newValue)
                })).frame(maxWidth: 30)
              default: Text("selected layer \(getActiveLayerIndex() ?? -1)")
            }
            Spacer()
            Button(action:{deleteAlertVisible = true}){
              Image(systemName: "trash").foregroundStyle(.red)
            }.alert("Delete Layer?", isPresented: $deleteAlertVisible){
              Button("Delete", role:.destructive) {
                deleteActiveLayer()
              }
            }
          }
        }.transition(.move(edge: .bottom)).frame(
          minWidth: UIScreen.main.bounds.width-10,
          maxHeight: 50
        )
      }.background(isLayerActive() ? .black : .gray)
      
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
          Button(action:addTextLayer) {
            Image(systemName: "textformat") .font(.system(size: iconSize))
          }
          Button(action:addColorLayer) {
            Image(systemName: "square.fill") .font(.system(size: iconSize))
          }
          PhotosPicker(selection:Binding<PhotosPickerItem?>(
            get: { nil },
            set: { item in
              guard let item = item else { return }
              Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                  layers.append(
                    Layer(
                      name: "Image Layer",
                      content: .image(Image(uiImage: image))
                    )
                  )
                }
              }
            }
          ),matching: .images){
            Image(systemName: "photo.badge.plus.fill")
                          .font(.system(size: iconSize))
          }
        }
        .padding(10).background(.black)
      }.background(.black)
    }.frame(maxHeight: 80).background(.gray)
  }
}
