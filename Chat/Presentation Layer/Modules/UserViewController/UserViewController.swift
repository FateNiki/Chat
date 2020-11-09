//
//  ViewController.swift
//  Chat
//
//  Created by Алексей Никитин on 12.09.2020.
//  Copyright © 2020 Алексей Никитин. All rights reserved.
//

import UIKit
import AVFoundation

private enum UserViewState {
    case viewing, editing, saving, loading
}

class UserViewController: UIViewController {
    // MARK: - Interface constants
    private let saveButtonBackground = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    private let saveButtonCornerRadius: CGFloat = 14
    
    // MARK: - Variables
    private var userData: UserStorageData {
        return UserStorageData(
            fullName: fullNameTextField.text ?? "",
            description: descriptionTextView.text,
            avatar: userAvatarView.avatar
        )
    }
    private var state: UserViewState = .viewing {
        didSet {
            switch state {
            case .viewing:
                editButton.isHidden = true
                fullNameTextField.isEnabled = false
                descriptionTextView.isEditable = false
                activityIndicator.stopAnimating()
                
                editButtonItem.isEnabled = true
                navigationItem.leftBarButtonItem?.isEnabled = true
                if #available(iOS 13, *) {
                    isModalInPresentation = false
                }
            case .editing:
                editButton.isHidden = false
                editButton.isEnabled = true
                fullNameTextField.isEnabled = true
                descriptionTextView.isEditable = true
                activityIndicator.stopAnimating()
                
                editButtonItem.isEnabled = true
                navigationItem.leftBarButtonItem?.isEnabled = true
                if #available(iOS 13, *) {
                    isModalInPresentation = false
                }
            case .saving, .loading:
                editButton.isHidden = false
                editButton.isEnabled = false
                fullNameTextField.isEnabled = false
                descriptionTextView.isEditable = false
                activityIndicator.startAnimating()
                
                editButtonItem.isEnabled = false
                navigationItem.leftBarButtonItem?.isEnabled = false
                if #available(iOS 13, *) {
                    isModalInPresentation = true
                }
            }
            updateSaveButtons()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet var saveButtons: [UIButton]!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var fullNameTextField: TurnedOffTextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var userAvatarView: UserAvatarView!
    @IBOutlet weak var scrollView: UIScrollView!

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
    
    // MARK: - Dependencies
    private let model: UserViewModelProtocol
    
    // MARK: - Lifecycle
    init(model: UserViewModelProtocol) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Interface configuring
    private func setupView() {
        configNavigation()
        configSaveButton()
        configKeyboard()
        addActivityIndicator()
        
        fullNameTextField.delegate = self
        descriptionTextView.delegate = self
        
        model.loadUser()
    }
    
    private func configKeyboard() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configNavigation() {
        navigationItem.title = "My profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeModal))
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    private func addActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func configSaveButton() {
        for saveButton in saveButtons {
            saveButton.backgroundColor = saveButtonBackground
            saveButton.layer.cornerRadius = saveButtonCornerRadius
            saveButton.clipsToBounds = true
        }
    }
    
    // MARK: - Helpers
    private func updateSaveButtons() {
        let isEnabled = state == .editing ? model.needSave(data: userData) : false
        saveButtons.forEach { $0.isEnabled = isEnabled }
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
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
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
        model.resetUserChanges()
    }
    
    @IBAction func saveByGCD() {
        model.saveUser(data: userData)
    }
    
    @IBAction func saveByOperations() {
        model.saveUser(data: userData)
    }
    
    @IBAction func fullNameDidChange(_ sender: Any) {
        updateSaveButtons()
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame: CGRect = keyboardValue.cgRectValue
        let keyboardViewEndFrame: CGRect = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
    }
}

extension UserViewController: UserViewModelDelegate {
    private func setup(user: User) {
        fullNameTextField.text = user.fullName
        descriptionTextView.text = user.description
        userAvatarView.configure(with: user.avatarModel())
    }
    
    // Reset
    func userDidReset(user: User) {
        setup(user: user)
    }
    
    // Load
    func userWillLoad() {
        self.state = .loading
    }
    
    func userDidLoad(user: User) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.state = .viewing
            self.setup(user: user)
        }
    }
    
    func showLoadingError(errors: UserStorageError) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let messages = errors.joined(separator: "\r\n")
            self.openAlert(title: "Ошибка сохранения", message: messages)
        }
    }
    
    // Save
    func userWillSave() {
        self.state = .saving
    }
    
    func userDidSave(user: User) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.state = .viewing
            self.setup(user: user)
            self.openAlert(title: "Сохранено успешно", message: "")
            self.setEditing(false, animated: true)
        }
    }

    func retrySave(errors: UserStorageError) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let messages = errors.joined(separator: "\r\n")
            let okButton = UIAlertAction(title: "Ok", style: .cancel, handler: {_ in
                self.setEditing(false, animated: true)
            })
            let repeatButton = UIAlertAction(title: "Повторить", style: .default, handler: {_ in
                self.model.saveUser(data: self.userData)
            })

            self.openAlert(title: "Ошибка сохранения", message: messages, buttons: [
                okButton,
                repeatButton
            ])
        }
    }
}

// MARK: - Work with textfields
extension UserViewController: UITextFieldDelegate, UITextViewDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 24
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateSaveButtons()
    }
}

// MARK: - Work with ImagePicker
extension UserViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func selectImageFrom(_ source: UIImagePickerController.SourceType) {
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
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            openAlert(title: "Изображение", message: "Image not found!")
            return
        }
        userAvatarView.configure(avatar: selectedImage.jpegData(compressionQuality: 1))
        updateSaveButtons()
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
                        self.openAlert(title: "Камера", message: "Доступ к камере не предоставлен")
                    }
                }
            }
        default:
            openAlert(title: "Камера", message: "Доступ к камере не предоставлен")
            return
        }
    }
}
