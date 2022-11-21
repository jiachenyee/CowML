//
//  CowDetectionManager.swift
//  CowML
//
//  Created by Jia Chen Yee on 30/1/23.
//

import Foundation
import Vision
import UIKit
import SwiftUI
import PhotosUI

class CowDetectionManager: ObservableObject {
    
    @Published var state: CowDetectionStateMachine = .noPhoto
    
    var photo: PhotosPickerItem? {
        get {
            switch state {
            case .loadingPhoto(let photo):
                return photo
            default:
                return nil
            }
        }
        set {
            if let newValue {
                state = .loadingPhoto(newValue)
                loadImage()
            }
        }
    }
    
    lazy var request: VNCoreMLRequest = {
        guard let model = try? VNCoreMLModel(for: MobileNetV2(configuration: .init()).model) else {
            fatalError("Could not load model")
        }
        
        let request = VNCoreMLRequest(model: model) { [self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                return
            }
            
            Task {
                await MainActor.run {
                    switch state {
                    case .processing(let image):
                        state = .detectionResult(topResult.identifier.contains("ox"), image)
                    default: break
                    }
                }
            }
        }
        
        return request
    }()
    
    func loadImage() {
        Task {
            if let data = try? await photo?.loadTransferable(type: Data.self),
               let finalImage = UIImage(data: data) {
                await MainActor.run {
                    state = .photoImported(finalImage)
                }
            }
        }
    }
    
    func detect(with image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        state = .processing(image)
        
        Task {
            try handler.perform([request])
        }
    }
}
