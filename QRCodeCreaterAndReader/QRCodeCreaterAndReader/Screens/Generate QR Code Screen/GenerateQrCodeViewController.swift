//
//  GenerateQrCodeViewController.swift
//  QRCodeCreaterAndReader
//
//  Created by Barkın Süngü on 13.12.2023.
//

import UIKit

class GenerateQrCodeViewController: UIViewController {
    
    // Create UI Elemenets
    let imageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .darkGray
        image.layer.cornerRadius = 10
        image.layer.borderWidth = 2.0
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 2.0
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let generateQRCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(generateQRCodeButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2.0 // Çizgi kalınlığını ayarlayın
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture) // Close keyboard when tapped anywhere
        
        setupLayout()
    }
    
    //Set UI Elements
    func setupLayout() {
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        view.addSubview(textField)
        view.addSubview(generateQRCodeButton)
        
        imageView.layer.borderColor = UIColor.black.cgColor
        
        if let placeholder = textField.placeholder {
            let attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            )
            textField.attributedPlaceholder = attributedPlaceholder
        }
        textField.placeholder = "   Type Text Want to Create Qr Code"
        
        generateQRCodeButton.layer.borderColor = UIColor.black.cgColor
        generateQRCodeButton.setTitleColor(.black, for: .normal)
        generateQRCodeButton.backgroundColor = .darkGray
        generateQRCodeButton.setTitle("  Generate QR Code  ", for: .normal)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 256),
            imageView.heightAnchor.constraint(equalToConstant: 256),
            
            textField.heightAnchor.constraint(equalToConstant: 50),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textField.bottomAnchor.constraint(equalTo: generateQRCodeButton.topAnchor, constant: -20),
            
            generateQRCodeButton.heightAnchor.constraint(equalToConstant: 50),
            generateQRCodeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            generateQRCodeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            generateQRCodeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        textField.addTarget(self, action: #selector(textFieldTapped), for: .editingDidBegin) //Get keyboard when tapped text field
    }

    @objc func generateQRCodeButtonTapped() {
        if let text = textField.text {
            if let qrCode = generateQRCode(from: text) {
                imageView.image = qrCode
            }
        }
    }

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                print("Code dönüyor")
                return UIImage(ciImage: output)
            }
        }
        print("boş dönüyor")
        return nil
    }
    
    @objc func textFieldTapped() {
        textField.becomeFirstResponder() //et keyboard
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true) //Close keyboard
    }
    
}
