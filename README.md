<img src="https://github.com/hexagons/SwiftMetal/blob/master/Assets/SwiftMetal-Bond-Logo-Mini.png?raw=true" width="155"/> 

# SwiftMetal

[![License](https://img.shields.io/cocoapods/l/SwiftMetal.svg)](https://github.com/hexagons/SwiftMetal/blob/master/LICENSE)
[![Cocoapods](https://img.shields.io/cocoapods/v/SwiftMetal.svg)](http://cocoapods.org/pods/SwiftMetal)
[![Platform](https://img.shields.io/cocoapods/p/SwiftMetal.svg)](http://cocoapods.org/pods/SwiftMetal)
<img src="https://img.shields.io/badge/in-swift5.0-orange.svg">

## Install

Swift Package or CocoaPods

```ruby
pod 'SwiftMetal'
```

## Write Metal in Swift

~~~~swift
import SwiftMetal
~~~~

~~~~swift
let add: SMFunc<SMFloat4> = function { args -> SMFloat4 in
    let a = args[0] as! SMFloat4
    let b = args[1] as! SMFloat4
    return a + b
}
let shader = SMShader { uv in
    let a = float4(0.1, 0.0, 0.0, 1.0)
    let b = float4(0.2, 0.0, 0.0, 1.0)
    let t = SMTexture(image: UIImage(named: "photo1")!)!
    let c: SMFloat4 = add.call(a, a) * add.call(b, b) + t
    return c
}
let res = CGSize(width: 1024, height: 1024)
let render: SMTexture = try! SMRenderer.render(shader: shader, at: res)
let image: UIImage = try! render.image()
let texture: MTLTexture = render.texture
~~~~


## Write Metal in SwiftUI

~~~~swift
import SwiftUI
import SwiftMetal
~~~~

~~~~swift
struct ContentView: View {
    @State var value: Float = 0.5
    var body: some View {
        VStack {
            Slider(value: $value)
            SMView {
                SMShader { uv in
                    let tex1 = SMTexture(image: UIImage(named: "photo1")!)!
                    let tex2 = SMTexture(image: UIImage(named: "photo2")!)!
                    let val = SMLiveFloat(self.$value)
                    return tex1.sample(at: uv + float2(tex2.r * -val, 0.0))
                }
            }
                .aspectRatio(1.5, contentMode: .fit)
                .cornerRadius(10)
        }
    }
}
~~~~


## Auto generated Metal code

Generated from first Swift example.

~~~~metal
#include <metal_stdlib>
using namespace metal;

float4 f0(float4 a0, float4 a1) {
    return (a0 + a1);
}

kernel void swiftMetal(
        texture2d<float, access::write> tex [[ texture(0) ]],
        texture2d<float, access::read> tex0 [[ texture(1) ]],
        uint2 pos [[ thread_position_in_grid ]],
        sampler smp [[ sampler(0) ]]
) {
    
    if (pos.x >= tex.get_width() || pos.y >= tex.get_height()) { return; }
    
    float4 t0 = tex0.read(pos);
    
    float4 v0 = float4(0.1, 0.0, 0.0, 1.0);
    float4 v1 = float4(0.2, 0.0, 0.0, 1.0);
    
    float4 val = ((f0(v0, v0) * f0(v1, v1)) + t0);
    
    tex.write(val, pos);
    
}
~~~~
