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

kernel void swiftMetal(constant Uniforms& us [[ buffer(0) ]],
                       texture2d<float, access::write> tex [[ texture(0) ]],
                       texture2d<float, access::read> tex0 [[ texture(1) ]],
                       texture2d<float, access::sample> tex1 [[ texture(2) ]],
                       uint2 pos [[ thread_position_in_grid ]],
                       sampler smp [[ sampler(0) ]]) {
    
    int x = pos.x;
    int y = pos.y;
    int w = tex.get_width();
    int h = tex.get_height();
    
    if (x >= w || y >= h) { return; }
    
    float u = (float(x) + 0.5) / float(w);
    float v = (float(y) + 0.5) / float(h);
    float2 uv = float2(u, v);
    
    float4 t0 = tex0.read(pos);
    float4 t1 = tex1.sample(smp, uv);
    float4 k0 = float4(0);
    
    float4 val = f0(t0) + float4(us.u0, 0.0, 0.0, 1.0) * t1 + k0;
    
    tex.write(val, pos);
    
}
