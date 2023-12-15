import UIKit
import AVFoundation

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    let qrCodeTextLabel = UILabel()
    let resetButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create camera preview screen
        setupCamera()

        // Create a TextField to show QR code
        setupLayout()

        // Start camera preview screen
        captureSession.startRunning()
    }

    func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        // Set preview size
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 1)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Set MetadataOutputs frame
        metadataOutput.rectOfInterest = CGRect(x: 0, y: 0, width: 1, height: 0.7)
    }

    func setupLayout() {
        qrCodeTextLabel.backgroundColor = .black
        qrCodeTextLabel.translatesAutoresizingMaskIntoConstraints = false
        qrCodeTextLabel.isUserInteractionEnabled = true // UILabel'ı etkileşimli hale getir
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textLabelTapped))
        qrCodeTextLabel.addGestureRecognizer(tapGesture)
        
        resetButton.setTitle("   Reset   ", for: .normal)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        resetButton.backgroundColor = .black
        resetButton.layer.cornerRadius = 10
        resetButton.layer.borderWidth = 2.0 // Çizgi kalınlığını ayarlayın
        resetButton.translatesAutoresizingMaskIntoConstraints = false

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(white: 0, alpha: 0.5) // get darker background

        view.addSubview(containerView)
        containerView.addSubview(qrCodeTextLabel)
        containerView.addSubview(resetButton)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),

            qrCodeTextLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            qrCodeTextLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            qrCodeTextLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            qrCodeTextLabel.heightAnchor.constraint(equalToConstant: 40),
            
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.topAnchor.constraint(equalTo: qrCodeTextLabel.bottomAnchor, constant: 20),
            resetButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning fail", message: "Can not found device camera", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession.stopRunning()
    }

    // This method is called when the QR code is detected
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            // Write QR code to TextField
            qrCodeTextLabel.text = stringValue

            // Stop camera
            captureSession.stopRunning()
        }
    }
    
    @objc func resetButtonTapped() {
        // Start camera
        captureSession.startRunning()
    }
    
    @objc func textLabelTapped(_ sender: UITapGestureRecognizer) {
        showCopyButton(for: qrCodeTextLabel, at: sender.location(in: qrCodeTextLabel))
    }

    func showCopyButton(for label: UILabel, at location: CGPoint) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Copy", style: .default, handler: { [weak self] _ in
            guard let textToCopy = label.text else { return }
            UIPasteboard.general.string = textToCopy

            let alert = UIAlertController(title: "Copied", message: "Text copied to clipborad", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = label
            popoverController.sourceRect = CGRect(x: location.x, y: location.y, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.up, .down]
        }

        present(alertController, animated: true, completion: nil)
    }
}
