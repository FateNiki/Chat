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
    public var currentUser: User = mockUser
    fileprivate var imagePicker: UIImagePickerController!

    
    // MARK: - Outlets
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userAvatarView: UserAvatarView!

    
    
    // MARK: - Lifecycle
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // print(saveButton.frame)
        // Невозможно обратиться к saveButton (runtime failure). В данный момент он равен nil
        // Кнопка инициализируется только после загрузки storyboard
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configSaveButton()
        initUserFields()
        
        print(saveButton.frame)
        // В данный момент View только загрузилась из связанного storyboard файла
        // и frame указаны в соответствии с текущими значениями для выбранного в сториборд устройстве.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(saveButton.frame)
        // В данный момент View уже отобразилась на экране устройства
        // Уже отработал механизм autolayout для текущего устройства
        // Так как в сториборд файле и эмуляторе выбраны устройства с разными экранами (iphone se 2 и iphone 11)
        // то и фреймы saveButton в них разные
        // viewDidLoad → (56.0, 597.0, 263.0, 40.0)
        // viewDidAppear → (56.0, 792.0, 302.0, 40.0)

    }
    
    // MARK: - Interface configuring    
    private func configSaveButton() -> Void {
        saveButton.backgroundColor = saveButtonBackground
        saveButton.layer.cornerRadius = saveButtonCornerRadius
        saveButton.clipsToBounds = true
    }
    
    private func initUserFields() -> Void {
        fullNameLabel.text = currentUser.fullName
        descriptionLabel.text = currentUser.description
        userAvatarView.configure(with: currentUser)
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
        currentUser.avatar = selectedImage.jpegData(compressionQuality: 1)
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

