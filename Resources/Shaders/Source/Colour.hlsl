#ifndef Colour_hlsl
#define Colour_hlsl

#include "Common.hlsl"

// Conversion: sRGB to Linear

TEMPLATE_1_REAL(Colour_ConvertSRGBToLinear, colour, return lerp(pow((colour + 0.055) / (1.055), 2.4), colour / 12.92, colour <= 0.04045h));

// Conversion: Linear to sRGB

TEMPLATE_1_REAL(Colour_ConvertLinearToSRGB, colour, return lerp(1.055 * pow(colour, 1.0 / 2.4) - 0.055, colour * 12.92, colour <= 0.0031308));

real Colour_Luminance(real3 colour) {
    return 0.25 * colour.r + 0.5 * colour.g + 0.25 * colour.b;
}

#endif // ifndef Colour_hlsl