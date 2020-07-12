#include "../Colour.hlsl"

// Function Constants

constant_var uint TextureTypeFloat = 0;
constant_var uint TextureTypeUInt = 1;

[[vk::constant_id(0)]] uint32_t fcImGuiTextureType = 0;
[[vk::constant_id(1)]] uint32_t fcImGuiTextureChannelCount = 4;
[[vk::constant_id(2)]] bool fcImGuiTextureConvertLinearToSRGB = false;

// Structures

struct ImGuiVertex {
    float2 position : POSITION;
    float2 tex_coords : TEXCOORD0;
    real4 color : COLOR;
};

struct ImGuiFragment {
    float4 position : SV_Position;
    real4 color : COLOR0;
    float2 tex_coords : TEXCOORD;
};

struct ImGuiVertexUniforms {
    float4x4 projectionMatrix;
};

[[vk::push_constant]] ImGuiVertexUniforms uniforms;

[shader("vertex")]
ImGuiFragment ImGuiPass_Vertex(ImGuiVertex input) {
    ImGuiFragment output;
    output.position = mul(uniforms.projectionMatrix, float4(input.position.xy, 0.f, 1.0) );
    output.color = real4(Colour_ConvertSRGBToLinear(input.color.rgb), input.color.a);
    output.tex_coords  = input.tex_coords;
    return output;
}

[[vk::binding(0, 0)]] sampler textureSampler;
[[vk::binding(1, 0)]] Texture2D<float4> floatTexture;
// [[vk::binding(2, 0)]] Texture2D<uint4> uintTexture;

[shader("pixel")]
real4 ImGuiPass_Fragment(ImGuiFragment input) : SV_Target {

    real4 textureColourValue;
    switch (fcImGuiTextureType) {
        case TextureTypeFloat:
            textureColourValue = real4(floatTexture.Sample(textureSampler, input.tex_coords));
            break;
        // case TextureTypeUInt:
        //     textureColourValue = real4(uintTexture.Load(int3(int2(input.tex_coords), 0)));
        //     break;
        default:
            textureColourValue = 1.0;
            break;
    }

    if (fcImGuiTextureConvertLinearToSRGB) {
        textureColourValue.rgb = Colour_ConvertLinearToSRGB(textureColourValue.rgb);
    }

    switch (fcImGuiTextureChannelCount) {
    case 1:
        textureColourValue = textureColourValue.rrrr;
        break;
    case 2:
        textureColourValue = real4(textureColourValue.rg, 0, 1);
        break;
    case 3:
        textureColourValue.a = 1;
    default:
        break;
    }

    return input.color * textureColourValue; 
}