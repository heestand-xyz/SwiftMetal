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
        #if DEBUG
        print(shader.code())
        #endif
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
#endif


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
            fatalError("SwiftMetal - SMUIView - Render Setup Error: \(error.localizedDescription)")
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
