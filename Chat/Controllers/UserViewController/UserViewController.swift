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
    private let saveButtonBackground = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    private let saveButtonCornerRadius: CGFloat = 14
    
    // MARK: - Variables
    var currentUser: User?
    fileprivate var imagePicker: UIImagePickerController!

    
    // MARK: - Outlets
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userAvatarView: UserAvatarView!

    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Interface configuring
    private func setupView() {
        configSaveButton()
        initUserFields()
    }
    
    private func configSaveButton() -> Void {
        saveButton.backgroundColor = saveButtonBackground
        saveButton.layer.cornerRadius = saveButtonCornerRadius
        saveButton.clipsToBounds = true
    }
    
    private func initUserFields() -> Void {
        guard let user = currentUser else { return }
        
        fullNameLabel.text = user.fullName
        descriptionLabel.text = user.description
        userAvatarView.configure(with: user)
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
                imagePicker.cameraCaptureMode = .photo
                requestCameraPermission {
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
            openErrorAlert(title: "Изображение", message: "Image not found!")
            return
        }
        currentUser?.avatar = selectedImage.jpegData(compressionQuality: 1)
        initUserFields()
    }
        
    private func requestCameraPermission(_ openImagePicker: @escaping () -> Void) {
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

