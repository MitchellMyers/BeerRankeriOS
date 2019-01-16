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
import Vision

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    private var textDetectionRequest: VNDetectTextRectanglesRequest?
    private var textObservations = [VNTextObservation]()
    private var beerTitles = [String]()
    var recognizedTextPositionTuples: [CGRect : (String, CGRect)] = [:]
    var positionToLayerDict : [CGRect : CALayer] = [:]
    private let session = AVCaptureSession()
    private var tesseract = G8Tesseract(language: "eng", engineMode: .tesseractOnly)
    
    var captureSession: AVCaptureSession?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    @objc var captureDevice: AVCaptureDevice?
    private var font = CTFontCreateWithName("Helvetica" as CFString, 8, nil)

    @IBOutlet var preView: UIView!
    @IBOutlet var capture: UIButton!
    @IBOutlet weak var checkBeerButton: UIButton!
    
    @IBAction func capture(_ sender: Any) {
        self.session.stopRunning()
        checkBeerButton.isEnabled = true
    }
    
    @IBAction func testWebscraper(_ sender: Any) {
        let ws = WebScrapingService()
//        ws.scrapeGoogleSearch(beerPhraseToSearch: "Stone Scorpion Bowl IPA df 65%") { response in
//            if let beerAdvUrl = response {
//                ws.scrapeBeerAdvocate(beerAdvUrl: beerAdvUrl) { response in
//                    print(response)
//                }
//            }
//        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        checkBeerButton.isEnabled = false
        tesseract?.pageSegmentationMode = .auto
        self.configureTextDetection()
        self.configureCamera()
        
    }
    
    private func configureCamera() {
        cameraView.session = session
        
        let cameraDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        var cameraDevice: AVCaptureDevice?
        for device in cameraDevices.devices {
            if device.position == .back {
                cameraDevice = device
                break
            }
        }
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: cameraDevice!)
            if session.canAddInput(captureDeviceInput) {
                session.addInput(captureDeviceInput)
            }
        }
        catch {
            print("Error occured \(error)")
            return
        }
        session.sessionPreset = .high
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Buffer Queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        cameraView.videoPreviewLayer.videoGravity = .resize
        session.startRunning()
    }
    
    private var cameraView: CameraView {
        return preView as! CameraView
    }
    
    private func configureTextDetection() {
        textDetectionRequest = VNDetectTextRectanglesRequest(completionHandler: handleDetection)
        textDetectionRequest?.reportCharacterBoxes = true
    }
    
    private func handleDetection(request: VNRequest, error: Error?) {
        
        guard let detectionResults = request.results else {
            print("No detection results")
            return
        }
        let textResults = detectionResults.map() {
            return $0 as? VNTextObservation
        }
        if textResults.isEmpty {
            return
        }
        textObservations = textResults as! [VNTextObservation]
        DispatchQueue.main.async {
            
            guard let sublayers = self.preView.layer.sublayers else {
                return
            }
            for layer in sublayers[1...] {
                if (layer as? CATextLayer) == nil {
                    layer.removeFromSuperlayer()
                }
            }
            let viewWidth = self.preView.frame.size.width
            let viewHeight = self.preView.frame.size.height
            for result in textResults {
                
                if let textResult = result {
                    
                    let layer = CALayer()
                    var rect = textResult.boundingBox
                    rect.origin.x *= viewWidth
                    rect.size.height *= viewHeight
                    rect.origin.y = ((1 - rect.origin.y) * viewHeight) - rect.size.height
                    rect.size.width *= viewWidth
                    
                    layer.frame = rect
                    layer.borderWidth = 2
                    layer.borderColor = UIColor.red.cgColor
                    self.preView.layer.addSublayer(layer)
                    
                    self.positionToLayerDict[textResult.boundingBox] = layer
                }
            }
        }
    }
    
    
    @IBAction func checkBeers(_ sender: Any) {
//        var finalString = ""
//        for text in beerTitles {
//            finalString.append(text)
//            finalString.append("\n")
//        }
        self.findBeerRatings() { response in
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "BeerInfoTableViewController") as! BeerInfoTableViewController
            myVC.allBeerInfoTupples = response
            self.navigationController?.pushViewController(myVC, animated: true)
        }
        
        
    }
    
    private func findBeerRatings(completion: @escaping ([(String?, String?, String?)]) -> Void) {
        var beerInfoTupples = [(String?, String?, String?)]()
        for beerTitle in self.beerTitles {
            self.findBeerRating(beerTitle: beerTitle) { response in
                beerInfoTupples.append(response)
                completion(beerInfoTupples)
            }
        }
    }
    
    private func findBeerRating(beerTitle: String, completion: @escaping ((String?, String?, String?)) -> Void) {
        let ws : WebScrapingService = WebScrapingService()
        ws.scrapeGoogleSearch(beerPhraseToSearch: beerTitle) { response in
            if let beerAdvUrl = response {
                ws.scrapeBeerAdvocate(beerAdvUrl: beerAdvUrl) { beerInfo in
                    //                        print(response)
                    completion(beerInfo)
                }
            }
        }
    }
    
    @IBAction func selectBlocksOfText(_ sender: UIPanGestureRecognizer) {
        sender.maximumNumberOfTouches = 1
        var location : CGPoint
        if sender.state == .began {
            location = sender.location(in: self.preView!)
            self.checkTapWithBoundBoxes(touch: location)
        }
        
        if sender.state != .cancelled {
            location = sender.location(in: preView!)
            self.checkTapWithBoundBoxes(touch: location)
        }
        
    }
    
    private func checkTapWithBoundBoxes(touch: CGPoint) {
        let scaledLoc = CGPoint(x: 1 - (touch.x / self.preView.frame.size.width), y: 1 - (touch.y / self.preView.frame.size.height))
        for (_, (text, boundBox)) in self.recognizedTextPositionTuples {
            if (boundBox.contains(scaledLoc)) {
                let corrLayer = self.positionToLayerDict[boundBox]
                corrLayer?.borderColor = UIColor.blue.cgColor
                if (!beerTitles.contains(text)) {
                    beerTitles.append(text)
                }
            }
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

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: - Camera Delegate and Setup
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        var imageRequestOptions = [VNImageOption: Any]()
        if let cameraData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            imageRequestOptions[.cameraIntrinsics] = cameraData
        }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: imageRequestOptions)
        do {
            try imageRequestHandler.perform([textDetectionRequest!])
        }
        catch {
            print("Error occured \(error)")
        }
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let transform = ciImage.orientationTransform(for: CGImagePropertyOrientation(rawValue: 6)!)
        ciImage = ciImage.transformed(by: transform)
        let size = ciImage.extent.size
        
        var newTextPositionTuples: [CGRect : (String, CGRect)] = [:]
        for textObservation in textObservations {
            
            guard let rects = textObservation.characterBoxes else {
                continue
            }
            
            var xMin = CGFloat.greatestFiniteMagnitude
            var xMax: CGFloat = 0
            var yMin = CGFloat.greatestFiniteMagnitude
            var yMax: CGFloat = 0
            for rect in rects {
                
                xMin = min(xMin, rect.bottomLeft.x)
                xMax = max(xMax, rect.bottomRight.x)
                yMin = min(yMin, rect.bottomRight.y)
                yMax = max(yMax, rect.topRight.y)
            }
            let imageRect = CGRect(x: (xMin * size.width) - 5, y: (yMin * size.height) - 5, width: ((xMax - xMin) * size.width) + 10, height: ((yMax - yMin) * size.height) + 10)
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(ciImage, from: imageRect) else {
                continue
            }
            let uiImage = UIImage(cgImage: cgImage)
            tesseract?.image = uiImage
            tesseract?.recognize()
            guard var text = tesseract?.recognizedText else {
                continue
            }
            text = text.trimmingCharacters(in: CharacterSet.newlines)
            if !text.isEmpty {
                let x = xMin
                let y = 1 - yMax
                let width = xMax - xMin
                let height = yMax - yMin
                newTextPositionTuples[CGRect(x: x, y: y, width: width, height: height)] = (text, textObservation.boundingBox)
//                newTextPositionTuples.append((rect: CGRect(x: x, y: y, width: width, height: height), text: text))
            }
        }
        textObservations.removeAll()
        DispatchQueue.main.async {
            let viewWidth = self.view.frame.size.width
            let viewHeight = self.view.frame.size.height
            guard let sublayers = self.view.layer.sublayers else {
                return
            }
            for layer in sublayers[1...] {
                
                if let _ = layer as? CATextLayer {
                    layer.removeFromSuperlayer()
                }
            }
            for (tupRect, (tupText, _)) in newTextPositionTuples {
                let textLayer = CATextLayer()
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.font = self.font
                var rect = tupRect

                rect.origin.x *= viewWidth
                rect.size.width *= viewWidth
                rect.origin.y *= viewHeight
                rect.size.height *= viewHeight

                // Increase the size of text layer to show text of large lengths
                rect.size.width += 100
                rect.size.height += 100

                textLayer.frame = rect
                textLayer.string = tupText
                textLayer.foregroundColor = UIColor.green.cgColor
//                self.view.layer.addSublayer(textLayer)
            }
            self.recognizedTextPositionTuples = newTextPositionTuples
        }
    }
}

extension CGRect: Hashable {
    public var hashValue: Int {
        return NSCoder.string(for: self).hashValue
    }
}

