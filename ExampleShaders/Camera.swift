//
//  Camera.swift
//  SwiftMetal_iOS
//
//  Created by Anton Heestand on 2019-12-12.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SwiftUI
import SwiftMetal
import AVKit

struct CameraView: View {
    @ObservedObject var camera: Camera = Camera.main
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            SMView {
                SMShader { uv in
                    SMLiveTexture(self.$camera.pixelBuffer)
                        .sample(at: SMFloat2(uv.y, 1.0 - uv.x))
                }
            }
                .aspectRatio(9 / 16, contentMode: .fit)
        }
    }
}

class Camera: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    static let main = Camera()
    
    @Published var pixelBuffer: CVPixelBuffer?
        
    let device: AVCaptureDevice
    let session: AVCaptureSession
    let input: AVCaptureDeviceInput
    let output: AVCaptureVideoDataOutput
        
    override init() {
        device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)!
        session = AVCaptureSession()
        input = try! AVCaptureDeviceInput(device: device)
        output =  AVCaptureVideoDataOutput()
        super.init()
        setup()
    }
    
    func setup() {
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        guard session.canAddInput(input) else {
            print("Camera - Can't add input")
            return
        }
        session.addInput(input)
        guard session.canAddOutput(output) else {
            print("Camera - Can't add output")
            return
        }
        session.addOutput(output)
        let queue = DispatchQueue(label: "camera.queue")
        output.setSampleBufferDelegate(self, queue: queue)
        session.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Camera - Buffer get failed.")
            return
        }
        DispatchQueue.main.async {
            self.pixelBuffer = buffer
        }
    }
    
}
