# SwiftMetal

<img src="https://github.com/hexagons/SwiftMetal/blob/master/Assets/SwiftMetal-Bond-Logo-Mini.png?raw=true" width="155"/> 

## Write Metal in Swift

~~~~swift
let img = UIImage(named: "photo1")!
let f = SMFunc<SMFloat4> { args in
    (args[0] as! SMFloat4) +
    (args[1] as! SMFloat4)
}
let shader = SMShader {
    let a = float4(0.1, 0.0, 0.0, 1.0)
    let b = float4(0.2, 0.0, 0.0, 1.0)
    let tex = SMTexture(image: img)!
    let c: SMFloat4 = f.call(a, a) * f.call(b, b) + tex
    return c
}
let res = CGSize(width: 1024, height: 1024)
let render: SMTexture = try! renderer.render(shader: shader, at: res)
let texture: MTLTexture = render.texture
~~~~

## Auto generated Metal code

~~~~Metal
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
