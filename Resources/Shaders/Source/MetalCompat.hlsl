#ifndef MetalCompat_hlsl
#define MetalCompat_hlsl

#ifdef __METAL_STDLIB
#define METAL 1
#endif

#ifdef METAL

template<typename T>
struct StructuredBuffer {
public:
    const device T *data;
    
    inline T operator[](int index) const {
        return this->data[index];
    }
};

struct SamplerState {
public:
    sampler s;

    inline SamplerState(sampler _s) : s(_s) {}
};

struct SamplerComparisonState {
public:
    sampler s;

    inline SamplerComparisonState(sampler _s) : s(_s) {}
};

template<typename T>
struct Texture2D {
public:
    texture2d<T, access::sample> texture;
    
    inline Texture2D(texture2d<T> tex) : texture(tex) {}
    
    inline vec<T, 4> Sample(SamplerState s, float2 location) const {
        return texture.sample(s.s, location.xy);
    }

    inline vec<T, 4> SampleBias(SamplerState s, float2 location, float _bias) const {
        return texture.sample(s.s, location.xy, bias(_bias));
    }
};

template<typename T>
struct Texture2DArray {
public:
    texture2d_array<T, access::sample> texture;
    
    inline Texture2DArray(texture2d_array<T> tex) : texture(tex) {}

    inline vec<T, 4> Sample(SamplerState s, float3 location) const {
        return texture.sample(s.s, location.xy, uint(location.z));
    }

    inline vec<T, 4> SampleBias(SamplerState s, float3 location, float _bias) const {
        return texture.sample(s.s, location.xy, uint(location.z), bias(_bias));
    }
};

template<typename T>
struct Depth2DArray {
public:
    depth2d_array<T, access::sample> texture;

    inline Depth2DArray(depth2d_array<T> tex) : texture(tex) {}

    inline T SampleCmpLevelZero(SamplerComparisonState s, float3 location, float compareVal) const {
        return texture.sample_compare(s.s, location.xy, uint(location.z), compareVal, level(0));
    }
};

template<typename T>
struct DepthCubeArray {
public:
    depthcube_array<T, access::sample> texture;

    inline DepthCubeArray(depthcube_array<T> tex) : texture(tex) {}
    
    inline T SampleCmpLevelZero(SamplerComparisonState s, float4 location, float compareVal) const {
        return texture.sample_compare(s.s, location.xyz, uint(location.w), compareVal, level(0));
    }
};


template<typename T>
inline int asint(T x) {
    return as_type<int>(x);
}

template<typename T>
inline int asuint(T x) {
    return as_type<uint>(x);
}

template<typename T>
inline T rcp(T x) {
    return 1.0 / x;
}

inline float f16tof32(uint x) {
    return float(as_type<half>(ushort(x)));
} 

template<typename T>
inline void sincos(T x, thread T& sinVal, thread T& cosVal) {
    sinVal = sincos(x, cosVal);
}

template<typename T, int Cols, int Rows>
inline vec<T, Rows> mul(matrix<T, Cols, Rows> mat, vec<T, Rows> vect) {
    return mat * vect;
}

#endif

#ifdef METAL
#define INOUT_PARAM(type, name) thread type& name
#define OUT_PARAM(type, name) thread type& name
#define INOUT_PARAM_ARRAY(type, name, arrayLen) thread type (&name)[arrayLen]
#define OUT_PARAM_ARRAY(type, name, arrayLen) thread type (&name)[arrayLen]
#else
#define INOUT_PARAM(type, name) inout type name
#define OUT_PARAM(type, name) out type name
#define INOUT_PARAM_ARRAY(type, name, arrayLen) inout type name[arrayLen]
#define OUT_PARAM_ARRAY(type, name, arrayLen) out type name[arrayLen]
#endif

#ifdef METAL
#define TEXTURE_TYPE(type, channels) type
#else
#define TEXTURE_TYPE(type, channels) type##channels
#define Depth2DArray Texture2DArray
#define DepthCubeArray TextureCubeArray
#endif

#ifdef METAL
#define constant_var constant
#else 
#define constant_var static const
#endif

#ifdef METAL
#else
#define packed_float3 float3
#define packed_int3 int3
#define packed_uint3 uint3
#endif

#ifdef METAL
#define lerp mix
#endif

#endif // ifndef MetalCompat_hlsl
