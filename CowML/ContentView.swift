//
//  ContentView.swift
//  CowML
//
//  Created by Jia Chen Yee on 21/11/22.
//

import SwiftUI
import PhotosUI
import Vision

struct ContentView: View {
    
    @StateObject var detectionManager = CowDetectionManager()
    
    @State var isPhotoPickerPresented = false
    
    var body: some View {
        NavigationStack {
            Group {
                switch detectionManager.state {
                case .noPhoto:
                    Text("Select an image")
                case .loadingPhoto:
                    ProgressView()
                case .photoImported(let image):
                    VStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                        Button {
                            detectionManager.detect(with: image)
                        } label: {
                            Text("Cow?")
                                .padding()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .background(.orange)
                        }
                        .padding()
                    }
                case .processing:
                    ProgressView()
                case .detectionResult(let result, let image):
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                        
                        Text(result ? "COW" : "NOT COW")
                            .font(.system(size: 32, weight: .heavy))
                            .padding()
                            .background(result ? .green : .red)
                            .foregroundColor(result ? .black : .white)
                    }
                }
            }
            .toolbar {
                Button {
                    isPhotoPickerPresented = true
                } label: {
                    Image(systemName: "photo")
                }
            }
        }
        .photosPicker(isPresented: $isPhotoPickerPresented, selection: $detectionManager.photo)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
