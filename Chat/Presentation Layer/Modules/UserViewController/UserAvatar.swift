//
//  UserAvatar.swift
//  Chat
//
//  Created by Алексей Никитин on 16.11.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit
import AVFoundation

protocol AvatarPickerPrototype {
    var delegate: UserAvatarPickerDelegate? { get }

    func chooseImage()
}

protocol UserAvatarPickerDelegate: class {
    func userAvatarDidChange(avatar: Data?)
    func userAvatarDontChoose(with error: String)
}

class AvatarPicker: NSObject, AvatarPickerPrototype {
    private var source: UIImagePickerController.SourceType
    private weak var parentVC: UIViewController?
    private(set) weak var delegate: UserAvatarPickerDelegate?
        
    init(from source: UIImagePickerController.SourceType, in parent: UIViewController, delegate: UserAvatarPickerDelegate? = nil) {
        self.source = source
        self.parentVC = parent
        self.delegate = delegate
    }
    
    private func requestCameraPermission(_ openImagePicker: @escaping () -> Void) {
        let permission = AVCaptureDevice.authorizationStatus(for: .video)
        switch permission {
        case .authorized:
            openImagePicker()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        openImagePicker()
                    } else {
                        self?.delegate?.userAvatarDontChoose(with: "Доступ к камере не предоставлен")
//                        self.openAlert(title: "Камера", message: "Доступ к камере не предоставлен")
                    }
                }
            }
        default:
            self.delegate?.userAvatarDontChoose(with: "Доступ к камере не предоставлен")
//            openAlert(title: "Камера", message: "Доступ к камере не предоставлен")
            return
        }
    }
    
    func chooseImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
            requestCameraPermission {
                self.parentVC?.present(imagePicker, animated: true)
            }
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
            parentVC?.present(imagePicker, animated: true)
        default:
            return
        }
    }
}

extension AvatarPicker: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            delegate?.userAvatarDontChoose(with: "Image not found!")
            return
        }
        delegate?.userAvatarDidChange(avatar: selectedImage.jpegData(compressionQuality: 1))
    }
}
