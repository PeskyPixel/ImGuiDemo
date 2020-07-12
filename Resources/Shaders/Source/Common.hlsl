#ifndef Common_hlsl
#define Common_hlsl

#ifdef TARGET_VULKAN
#define REAL_IS_HALF 0
#endif

#ifndef REAL_IS_HALF
#define REAL_IS_HALF 1
#endif

#if REAL_IS_HALF
#define real half
#define real2 half2
#define real3 half3
#define real4 half4
#define real3x3 half3x3
#define REAL_MIN HALF_MIN
#define REAL_MAX HALF_MAX
#define REAL_EPS HALF_EPS
#else
#define REAL_MIN FLT_MIN
#define REAL_MAX FLT_MAX
#define REAL_EPS FLT_EPS
#define real float
#define real2 float2
#define real3 float3
#define real4 float4
#define real3x3 float3x3
#endif // ifndef real

#include "Macros.hlsl"
#include "MetalCompat.hlsl"

#define M_PI          3.14159265358979323846
#define M_TWO_PI      6.28318530717958647693
#define M_FOUR_PI     12.5663706143591729538
#define M_1_PI      0.31830988618379067154
#define M_1_TWO_PI  0.15915494309189533577
#define M_1_FOUR_PI 0.07957747154594766788
#define M_PI_2     1.57079632679489661923
#define M_2_PI 0.63661977236758134308
#define M_E 2.7182818284590452353602874
#define LOG2_E      1.44269504088896340736
#define M_SQRT_2 1.4142135624

#ifndef METAL
#define FLT_INF  asfloat(0x7F800000)
#define HALF_EPS 4.88e-04  // 2^-11, machine epsilon: 1 + EPS = 1 (half of the ULP for 1.0f)
#define FLT_EPS  5.960464478e-8  // 2^-24, machine epsilon: 1 + EPS = 1 (half of the ULP for 1.0f)
#define FLT_MIN  1.175494351e-38 // Minimum normalized positive floating-point number
#define FLT_MAX  3.402823466e+38 // Maximum representable floating-point number
#define HALF_MIN 6.103515625e-5  // 2^-14, the same value for 10, 11 and 16-bit: https://www.khronos.org/opengl/wiki/Small_Float_Formats
#define HALF_MAX 65504.0
#define UINT_MAX 0xFFFFFFFFu
#endif

typedef uint16_t ushort;

inline real SafeDiv(real numer, real denom) {
    return (numer != denom) ? numer / denom : 1;
}

// Building an Orthonormal Basis, Revisited. Duff et. al., Pixar. http://jcgt.org/published/0006/01/01/paper.pdf
inline void ConstructOrthonormalBasis(real3 n, OUT_PARAM(real3, b1), OUT_PARAM(real3, b2)) {
    real sign = n.z > 0.0 ? 1.0 : -1.0;
    const real a = -1.0 / (sign + n.z);
    const real b = n.x * n.y * a;
    b1 = real3(1.0 + sign * n.x * n.x * a, sign * b, -sign * n.x);
    b2 = real3(b, sign + n.y * n.y * a, -n.y);
}

struct AffineMatrix {
    float4 r0;
    float4 r1;
    float4 r2;
};

inline float4 AffineMatrix_MulVector(AffineMatrix mat, float4 vec) {
    float x = dot(mat.r0, vec);
    float y = dot(mat.r1, vec);
    float z = dot(mat.r2, vec);
    return float4(x, y, z, vec.w);
}

inline float3 AffineMatrix_MulPositionVector(AffineMatrix mat, float3 vec) {
    float x = dot(mat.r0.xyz, vec) + mat.r0.w;
    float y = dot(mat.r1.xyz, vec) + mat.r1.w;
    float z = dot(mat.r2.xyz, vec) + mat.r2.w;
    return float3(x, y, z);
}

inline float3 AffineMatrix_MulDirectionVector(AffineMatrix mat, float3 vec) {
    float x = dot(mat.r0.xyz, vec);
    float y = dot(mat.r1.xyz, vec);
    float z = dot(mat.r2.xyz, vec);
    return float3(x, y, z);
}

inline real square(real x) {
    return x * x;
}

#ifndef METAL
inline half distance_squared(half3 a, half3 b) {
    half3 delta = a - b;
    return dot(delta, delta);
}

inline float distance_squared(float3 a, float3 b) {
    float3 delta = a - b;
    return dot(delta, delta);
}
#endif

inline void CubeMap_FaceUVsToDirections(real2 uv, OUT_PARAM_ARRAY(real3, directions, 6)) {
    
    // All unnormalised since we're using them to fetch into a cubemap.
    
    real2 scaledUV = uv * 2 - 1;
    scaledUV.y *= -1;
    
    directions[0] = real3(1.0, scaledUV.y, -scaledUV.x);
    directions[1] = real3(-1.0, scaledUV.y, scaledUV.x);
    directions[2] = real3(scaledUV.x, 1.0, -scaledUV.y);
    directions[3] = real3(scaledUV.x, -1.0, scaledUV.y);
    directions[4] = real3(scaledUV.x, scaledUV.y, 1.0);
    directions[5] = real3(-scaledUV.x, scaledUV.y, -1.0);
}

// Goal: find the last index where values[index] <= value
inline uint BinarySearch(StructuredBuffer<uint> values, uint count, uint value) {
    uint low = 0;
    uint high = count;
    while (low != high) {
        uint mid = low + ((high - low) >> 1);
        if (values[mid] < value) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }
    low = min(low, count - 1);
    return values[low] <= value ? low : low - 1;
}

inline float CopySign(float x, float s) {
    return (s >= 0) ? abs(x) : -abs(x);
}

#endif // ifndef Common_hlsl
