//
//  ViewController.swift
//  Chat
//
//  Created by Алексей Никитин on 12.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit
import AVFoundation

class UserViewController: UIViewController {
    // MARK: - Interface constants
    private let lightGray = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    private let saveButtonCornerRadius: CGFloat = 14
    
    // MARK: - Variables
    public var currentUser: User = mockUser
    fileprivate var imagePicker: UIImagePickerController!

    
    // MARK: - Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configAvatarImageView()
        configSaveButton()
        
        initUserFields()
    }
    
    // MARK: - Interface configuring
    private func configAvatarImageView() -> Void {
        let minSize = min(avatarImageView.layer.frame.width, avatarImageView.layer.frame.height)
        avatarImageView.layer.cornerRadius = minSize / 2
        avatarImageView.backgroundColor = lightGray
    }
    
    private func configSaveButton() -> Void {
        saveButton.backgroundColor = lightGray
        saveButton.layer.cornerRadius = saveButtonCornerRadius
    }
    
    private func initUserFields() -> Void {
        fullNameLabel.text = currentUser.fullName
        descriptionLabel.text = currentUser.description
        if let avatarImageData = currentUser.avatar {
            avatarImageView.image = UIImage(data: avatarImageData)
        }
    }
    
    // MARK: - Inteface Actions
    @IBAction func editAvatarButtonDidTap(_ sender: UIButton) {
        let editAvatarDialog = UIAlertController(title: "Выбрать аватар", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Установить из галлереи", style: .default) { _ in
                self.selectImageFrom(.photoLibrary)
            }
            editAvatarDialog.addAction(photoLibraryAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera)  {
            let takePhotoAction = UIAlertAction(title: "Сделать фото", style: .default) { _ in
                self.selectImageFrom(.camera)
            }
            editAvatarDialog.addAction(takePhotoAction)
        }

        guard editAvatarDialog.actions.count > 0 else {
            return
        }
        
        editAvatarDialog.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        present(editAvatarDialog, animated: true)        
    }
    
    // MARK: - Helpers
    private func openErrorAlert(title: String, message: String) {
        let errorAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        errorAlertController.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
        present(errorAlertController, animated: true)
    }
}

// MARK: - Work with ImagePicker
extension UserViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    
    func selectImageFrom(_ source: ImageSource){
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        switch source {
            case .camera:
                imagePicker.sourceType = .camera
                takePhoto {
                    self.present(self.imagePicker, animated: true)
                }
            case .photoLibrary:
                imagePicker.sourceType = .photoLibrary
                present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        currentUser.avatar = selectedImage.pngData()
        initUserFields()
    }
        
    private func takePhoto(_ openImagePicker: @escaping () -> Void) {
        let permission = AVCaptureDevice.authorizationStatus(for: .video)
        switch permission {
            case .authorized:
                openImagePicker()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            openImagePicker()
                        } else {
                            self.openErrorAlert(title: "Камера", message: "Доступ к камере не предоставлен")
                        }
                    }
                }
            
            default:
                openErrorAlert(title: "Камера", message: "Доступ к камере не предоставлен")
                return
        }
    }
}

