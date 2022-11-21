//
//  CowDetectionStateMachine.swift
//  CowML
//
//  Created by Jia Chen Yee on 30/1/23.
//

import Foundation
import UIKit
import PhotosUI
import SwiftUI

enum CowDetectionStateMachine {
    case noPhoto
    case loadingPhoto(PhotosPickerItem)
    case photoImported(UIImage)
    case processing(UIImage)
    case detectionResult(Bool, UIImage)
}
