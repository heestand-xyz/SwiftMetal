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
let texture = try! SMRenderer.render(shader, at: res)
let image = try! texture.image()

print("Rendered!")

let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
let fileURL = desktopURL.appendingPathComponent("swift-metal-render.png")
let tiffRepresentation = NSBitmapImageRep(data: image.tiffRepresentation!)!
let pngData = tiffRepresentation.representation(using: .png, properties: [:])!
try! pngData.write(to: fileURL, options: .atomic)

print("Saved!")
