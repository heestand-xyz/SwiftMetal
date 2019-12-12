//
//  main.swift
//  SwiftMetalTool
//
//  Created by Hexagons on 2019-12-09.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Cocoa
import SwiftMetal

print("SwiftMetal")

let shader = SMShader { uv in
    float4(uv.x, uv.y, 0.0, 1.0)
}

print("Render...")

let res = CGSize(width: 4096, height: 4096)
let texture = try! SMRenderer.render(shader, at: res, as: .rgba32Float)
let image = try! texture.image()

print("Rendered!")

let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
let fileURL = desktopURL.appendingPathComponent("swift-metal-render-32.tiff")
let data: Data = image.tiffRepresentation!
try! data.write(to: fileURL, options: .atomic)
//let pngData = NSBitmapImageRep(data: data)!.representation(using: .png, properties: [:])!

print("Saved!")
