//
//  ViewController.swift
//  BeerRanker
//
//  Created by Mitchell Myers on 1/14/19.
//  Copyright © 2019 BreMy Software. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import TesseractOCR

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    var captureSession: AVCaptureSession?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    @objc var captureDevice: AVCaptureDevice?

    @IBOutlet var preView: UIView!
    @IBOutlet var capture: UIButton!
    
    @IBAction func capture(_ sender: Any) {
        let photoSettings : AVCapturePhotoSettings!
        photoSettings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.flashMode = .off
        photoSettings.isHighResolutionPhotoEnabled = false
        self.capturePhotoOutput?.capturePhoto(with: photoSettings, delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.captureSession = AVCaptureSession()
        self.captureSession?.sessionPreset = .photo
        self.capturePhotoOutput = AVCapturePhotoOutput()
        self.captureDevice = AVCaptureDevice.default(for: .video)
        let input = try! AVCaptureDeviceInput(device: self.captureDevice!)
        self.captureSession?.addInput(input)
        self.captureSession?.addOutput(self.capturePhotoOutput!)
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
        self.previewLayer?.frame = self.preView.bounds
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.preView.layer.addSublayer(self.previewLayer!)
        
        self.captureSession?.startRunning()
        
    }
    
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        PHPhotoLibrary.shared().performChanges( {
//            let creationRequest = PHAssetCreationRequest.forAsset()
//            creationRequest.addResource(with: PHAssetResourceType.photo, data: photo.fileDataRepresentation()!, options: nil)
//        }, completionHandler: nil)
//    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                              didFinishProcessingPhoto photo: AVCapturePhoto,
                              error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            print("Error while generating image from photo capture data.")
            return
        }
        // Initialise a UIImage with our image data
        let capturedImage = UIImage.init(data: imageData, scale: 7.5)
//        let imageView = UIImageView(image: capturedImage!)
//        self.preView.addSubview(imageView)
        handleWithTesseract(image: capturedImage!)
    }
    
    private func handleWithTesseract(image: UIImage) {
        let scaledImage = image.scaleImage(640)
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.engineMode = .tesseractCubeCombined
            tesseract.pageSegmentationMode = .auto
            tesseract.image = scaledImage?.g8_blackAndWhite()
            tesseract.recognize()
            let myVC = storyboard?.instantiateViewController(withIdentifier: "BeerInfoViewController") as! BeerInfoViewController
            myVC.beerInfo = tesseract.recognizedText
            navigationController?.pushViewController(myVC, animated: true)
        }
    }
    
    
    



}

extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

