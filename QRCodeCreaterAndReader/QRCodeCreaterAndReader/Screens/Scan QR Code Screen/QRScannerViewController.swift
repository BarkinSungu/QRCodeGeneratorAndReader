import UIKit
import AVFoundation

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    let qrCodeTextField = UITextField()
    let resetButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Kamera ön izleme ekranı oluştur
        setupCamera()

        // QR kodu göstermek için bir TextField oluştur
        setupLayout()

        // Kamera ön izleme başlat
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

        // Ön izleme boyutunu ayarla
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.7)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // MetadataOutput'un frame'ini ayarla
        metadataOutput.rectOfInterest = CGRect(x: 0, y: 0, width: 1, height: 0.7)
    }

    func setupLayout() {
        qrCodeTextField.borderStyle = .roundedRect
        qrCodeTextField.placeholder = "QR Kodu Buraya Yazın"
        qrCodeTextField.translatesAutoresizingMaskIntoConstraints = false
        
        resetButton.setTitle("Reset", for: .normal)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        resetButton.layer.cornerRadius = 10
        resetButton.layer.borderWidth = 2.0 // Çizgi kalınlığını ayarlayın
        resetButton.translatesAutoresizingMaskIntoConstraints = false

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(white: 0, alpha: 0.5) // İsterseniz bu satırı ekleyebilirsiniz, arkaplanı karanlıklaştırır

        view.addSubview(containerView)
        containerView.addSubview(qrCodeTextField)
        containerView.addSubview(resetButton)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),

            qrCodeTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            qrCodeTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            qrCodeTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            qrCodeTextField.heightAnchor.constraint(equalToConstant: 80),
            
            resetButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            resetButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            resetButton.topAnchor.constraint(equalTo: qrCodeTextField.bottomAnchor, constant: 20),
            resetButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func failed() {
        let ac = UIAlertController(title: "Tarama Başarısız", message: "Cihazınızın kamerasını kullanamıyoruz.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(ac, animated: true)
        captureSession.stopRunning()
    }

    // QR kodu tespit edildiğinde bu metod çağrılır
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            // QR kodu TextField'a yaz
            qrCodeTextField.text = stringValue

            // Kamerayı durdur
            captureSession.stopRunning()
        }
    }
    
    @objc func resetButtonTapped() {
        //Kamerayı çalıştır
        captureSession.startRunning()
    }
}
