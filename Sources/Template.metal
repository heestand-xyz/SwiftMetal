//
//  Template.metal
//  SwiftMetal
//
//  Created by Anton Heestand on 2019-12-06.
//  Copyright © 2019 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    float x;
};

kernel void swiftMetal(const device Uniforms& vars [[ buffer(0) ]],
                       texture2d<float, access::write> tex [[ texture(0) ]],
                       texture2d<float, access::read> tex0 [[ texture(1) ]],
                       uint2 pos [[ thread_position_in_grid ]],
                       sampler smp [[ sampler(0) ]]) {
    
    if (pos.x >= tex.get_width() || pos.y >= tex.get_height()) { return; }
    
    float4 t0 = tex0.read(pos);
    
    float4 val = float4(vars.x, 0.0, 0.0, 1.0);
    
    tex.write(val, pos);
    
}
