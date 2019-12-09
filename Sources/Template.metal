//
//  Template.metal
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float4 f0(float4 input) {
    return input + input;
}

struct Uniforms {
    float u0;
};

kernel void swiftMetal(const device Uniforms& us [[ buffer(0) ]],
                       texture2d<float, access::write> tex [[ texture(0) ]],
                       texture2d<float, access::read> tex0 [[ texture(1) ]],
                       uint2 pos [[ thread_position_in_grid ]],
                       sampler smp [[ sampler(0) ]]) {
    
    if (pos.x >= tex.get_width() || pos.y >= tex.get_height()) { return; }
    
    float4 t0 = tex0.read(pos);
    
    float4 val = f0(t0) + float4(us.u0, 0.0, 0.0, 1.0);
    
    tex.write(val, pos);
    
}
