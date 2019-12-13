//
//  SMView.swift
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-10.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import MetalKit
#if os(macOS)
import Cocoa
#else
import UIKit
#endif
import SwiftUI

#if os(macOS)
#else
public struct SMView: UIViewRepresentable {
    let shader: () -> (SMShader)
    public init(_ shader: @escaping () -> (SMShader)) {
        self.shader = shader
    }
    public func makeUIView(context: Self.Context) -> SMUIView {
        let shader = self.shader()
        return SMUIView(shader: shader)
    }
    public func updateUIView(_ view: SMUIView, context: Self.Context) {
        #if os(macOS)
        view.setNeedsDisplay(view.frame)
        #else
        view.setNeedsDisplay()
        #endif
    }
}
//struct SMSubReView<Content: View>: UIViewRepresentable {
//    let view: () -> (Content)
//    let update: () -> ()
//    init(view: @escaping () -> (Content), update: @escaping () -> ()) {
//        self.view = view
//        self.update = update
//    }
//    func makeUIView(context: Self.Context) -> UIView {
//        UIHostingController(rootView: view()).view!
//    }
//    func updateUIView(_ view: UIView, context: Self.Context) {
//        update()
//    }
//}
//public struct SMReView<Content: View>: UIViewRepresentable {
//    let shader: (SMTexture) -> (SMShader)
//    let view: () -> (Content)
//    public init(_ shader: @escaping (SMTexture) -> (SMShader), _ view: @escaping () -> (Content)) {
//        self.shader = shader
//        self.view = view
//    }
//    public func makeUIView(context: Self.Context) -> UIView {
//
//        var texture: SMTexture!
//        let subReView = SMSubReView<Content>(view: view, update: {
//            print("Update......")
//            texture.update()
//        })
//        let subView = UIHostingController(rootView: subReView).view!
//        texture = SMTexture(futureImage: {
//            guard subView.bounds.width > 0 else {
//                print("View Frame is Zero")
//                return nil
//            }
//            UIGraphicsBeginImageContextWithOptions(subView.bounds.size, false, 0)
//            subView.drawHierarchy(in: subView.bounds, afterScreenUpdates: true)
//            guard let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
//                print("View to Image Failed")
//                return nil
//            }
//            UIGraphicsEndImageContext()
//            return image
//        })
////        texture.update()
//
//        let shader = self.shader(texture)
//
//        let baseView = UIView()
//
//        let smUiView = SMUIView(shader: shader)
//        baseView.addSubview(smUiView)
//        smUiView.translatesAutoresizingMaskIntoConstraints = false
//        smUiView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
//        smUiView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor).isActive = true
//        smUiView.widthAnchor.constraint(equalTo: baseView.widthAnchor).isActive = true
//        smUiView.heightAnchor.constraint(equalTo: baseView.heightAnchor).isActive = true
//
//        baseView.addSubview(subView)
//        subView.alpha = 0.1
//        subView.translatesAutoresizingMaskIntoConstraints = false
//        subView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor).isActive = true
//        subView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor).isActive = true
//        subView.widthAnchor.constraint(equalTo: baseView.widthAnchor).isActive = true
//        subView.heightAnchor.constraint(equalTo: baseView.heightAnchor).isActive = true
//
//        return baseView
//    }
//    public func updateUIView(_ view: UIView, context: Self.Context) {
//        #if os(macOS)
//        view.subviews[0].setNeedsDisplay(view.frame)
//        #else
//        view.subviews[0].setNeedsDisplay()
//        #endif
//    }
//}
#endif

// MTKViewDelegate...

public class SMUIView: MTKView {
    
    var res: CGSize?
    
    var renderCallback: (() -> ())?
        
    let shader: SMShader
    
    public init(shader: SMShader) {
                
        self.shader = shader
        
        super.init(frame: .zero, device: SMRenderer.metalDevice)
        
//        colorPixelFormat = SMRenderer.defaultPixelFormat
        #if os(macOS)
        layer!.isOpaque = false
        #else
        isOpaque = false
        #endif
        framebufferOnly = false
        autoResizeDrawable = false
        enableSetNeedsDisplay = true
//        isPaused = true
        
        do {
            try SMRenderer.renderView(shader, in: self)
        } catch {
            fatalError("SwiftMetal - SMUIView - Render Setup Error: \(String(describing: error))")
        }
                
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
//        autoreleasepool {
        #if os(macOS)
        let scale: CGFloat = 1.0
        #else
        let scale: CGFloat = UIScreen.main.scale
        #endif
        res = CGSize(width: rect.size.width * scale,
                     height: rect.size.height * scale)
        guard res!.width > 0 && res!.height > 0 else { return }
        renderCallback?()
//        }
    }
    
    #if !os(macOS)
    public override func layoutIfNeeded() {
        super.layoutIfNeeded()
        print("layoutIfNeeded")
    }
    #endif
    
}
