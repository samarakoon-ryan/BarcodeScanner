//
//  ScannerVC.swift
//  BarcodeScanner
//
//  Created by Ryan on 10/23/23.
//

import UIKit
import AVFoundation

protocol ScannerVCDelegate: AnyObject {
    func didFind(barcode: String)
}

final class ScannerVC: UIViewController {
    
    // Capture Properties
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var scannerDelegate: ScannerVCDelegate!
    
    // Initializer
    init(scannerDelegate: ScannerVCDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.scannerDelegate = scannerDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Camera Setup
    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metaDataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metaDataOutput) {
            captureSession.addOutput(metaDataOutput)
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDataOutput.metadataObjectTypes = [.ean8, .ean13]
        } else {
            return
        }
        
        // Preview Layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
        
        // Start Capture Session
        captureSession.startRunning()
    }
}

extension ScannerVC: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // get metadata object
        guard let object = metadataObjects.first else {
            return
        }
        
        // get machine readable object
        guard let machineReadableObject = object as? AVMetadataMachineReadableCodeObject else {
            return
        }
        
        // get string value from machine readable object
        guard let barcode = machineReadableObject.stringValue else {
            return
        }
        
        // send string value to delegate
        scannerDelegate?.didFind(barcode: barcode)
    }
}
