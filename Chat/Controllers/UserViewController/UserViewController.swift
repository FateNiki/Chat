//
//  ViewController.swift
//  Chat
//
//  Created by Алексей Никитин on 12.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit
import AVFoundation

fileprivate enum UserViewState {
    case viewing, editing, saving
}

class UserViewController: UIViewController {
    // MARK: - Interface constants
    private let saveButtonBackground = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    private let saveButtonCornerRadius: CGFloat = 14
    
    // MARK: - Variables
    var currentUser: User?
    var delegate: UserViewDelegate?
    private var state: UserViewState = .viewing {
        didSet {
            switch state {
                case .viewing:
                    editButton.isHidden = true
                    saveButtons.forEach { $0.isEnabled = false }
                    fullNameTextField.isEnabled = false
                    descriptionTextView.isEditable = false
                    activityIndicator.stopAnimating()
                    editButtonItem.isEnabled = true
                case .editing:
                    editButton.isHidden = false
                    editButton.isEnabled = true
                    saveButtons.forEach { $0.isEnabled = true }
                    fullNameTextField.isEnabled = true
                    descriptionTextView.isEditable = true
                    activityIndicator.stopAnimating()
                    editButtonItem.isEnabled = true
                case .saving:
                    editButton.isHidden = false
                    editButton.isEnabled = false
                    saveButtons.forEach { $0.isEnabled = false }
                    fullNameTextField.isEnabled = false
                    descriptionTextView.isEditable = false
                    activityIndicator.startAnimating()
                    editButtonItem.isEnabled = false
            }
        }
    }
    

    
    // MARK: - Outlets
    @IBOutlet var saveButtons: [UIButton]!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var fullNameTextField: TurnedOffTextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var userAvatarView: UserAvatarView!
    
    // MARK: - UI Variables
    fileprivate var imagePicker: UIImagePickerController!
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return indicator
    }()

    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Interface configuring
    private func setupView() {
        configNavigation()
        configSaveButton()
        addActivityIndicator()
        initUserFields()
        
        state = .viewing
        fullNameTextField.delegate = self
    }
    
    private func configNavigation() {
        navigationItem.title = "My profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeModal))
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    private func addActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func configSaveButton() -> Void {
        for saveButton in saveButtons {
            saveButton.backgroundColor = saveButtonBackground
            saveButton.layer.cornerRadius = saveButtonCornerRadius
            saveButton.clipsToBounds = true
        }
    }
    
    private func initUserFields() -> Void {
        guard let user = currentUser else { return }
        
        fullNameTextField.text = user.fullName
        descriptionTextView.text = user.description
        userAvatarView.configure(with: UserAvatarModel(initials: user.initials, avatar: user.avatar))
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
    
    @objc func closeModal() {
        dismiss(animated: true, completion: nil)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        state = editing ? .editing : .viewing
        initUserFields()
    }
    
    @IBAction func saveByGCD() {
        saveUser(by: GCDUserManager.shared)
    }
    
    @IBAction func saveByOperations() {
        saveUser(by: OperationsUserManager.shared)
    }
    
    private func saveUser<M: UserManager>(by manager: M) {
        state = .saving
        manager.saveToFile(
            data: UserData(
                fullName: fullNameTextField.text ?? "",
                description: descriptionTextView.text,
                avatar: userAvatarView.avatar
            )
        ) { [weak self] user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.delegate?.userDidChange(newUser: user)
                self?.setEditing(false, animated: true)
            }
        }
    }
}

extension UserViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 24
    }
}

// MARK: - Work with ImagePicker
extension UserViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func selectImageFrom(_ source: UIImagePickerController.SourceType){
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
            default:
                return
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            openErrorAlert(title: "Изображение", message: "Image not found!")
            return
        }
        guard let user = currentUser else { return }
        userAvatarView.configure(with: UserAvatarModel(initials: user.initials, avatar: selectedImage.jpegData(compressionQuality: 1)))
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

