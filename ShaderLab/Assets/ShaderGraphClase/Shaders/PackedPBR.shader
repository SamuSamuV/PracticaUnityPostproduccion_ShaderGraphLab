Shader "Custom/PackedPBR"
{
    Properties
    {
        _mainTexture ("Main Texture", 2D) = "white" {}
        _normalTexture ("Normal Texture", 2D) = "bump" {}
        _normalIntensity ("Normal Intensity", Range(0, 5)) = 1.0
        _smoothness ("Smoothness Intensity", Range(0, 1)) = 0.5
        _ARMTexture ("ARM Texture", 2D) = "black" {}

        _metallicIntensity ("Metallic Intensity", Range(0, 1)) = 0.5
        _emissionTexture ("Emission Texture", 2D) = "black" {}
        _emissionIntensity ("Emission Intensity", Range(0,2)) = 0.5
        _emissionColor ("Emission Color", Color) = (0,0,0,1)
        _AOIntensity ("Ambient Occlusion Intensity", Range(0, 1)) = 1.0
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Standard

        struct Input
        {
            float2 uv_mainTexture;
            float2 uv_emissionTexture;
            float2 uv_normalTexture;
            float2 uv_ARMTexture;
        };

        sampler2D _mainTexture, _emissionTexture, _normalTexture, _ARMTexture;
        half _smoothness, _metallicIntensity, _emissionIntensity, _normalIntensity, _AOIntensity;
        float4 _emissionColor;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // fixed3 Albedo;   base (diffuse or specular) color
            // fixed3 Normal;   tangent space normal, if written
            // half3 Emission;
            // half Metallic;   0=non-metal, 1=metal
            // half Smoothness; 0=rough, 1=smooth
            // half Occlusion;  occlusion (default 1)
            // fixed Alpha;     alpha for transparencies

            o.Albedo = tex2D(_mainTexture, IN.uv_mainTexture).rgb;

            // ARM packed Texture
            // R(AO): Ambient occlusion
            // G(R): Roughness
            // B(M): Metallic
            float3 unpackedTex = tex2D(_ARMTexture, IN.uv_mainTexture);
            o.Occlusion = unpackedTex.r * _AOIntensity;
            o.Metallic = unpackedTex.g * _metallicIntensity;
            o.Smoothness = (float3(1, 1, 1) - unpackedTex.b) * _smoothness;

            float3 normalTex = UnpackNormal(tex2D(_normalTexture, IN.uv_normalTexture));
            float3 flatNormal = float3(0, 0, 1); // default flat normal
            o.Normal = normalize(lerp(flatNormal, normalTex, _normalIntensity));

            float3 emissionTex = tex2D(_emissionTexture, IN.uv_emissionTexture).rgb;
            float3 emissionTexGray = dot(emissionTex, float3(0.299, 0.587, 0.114));
            float3 emission = (emissionTexGray * float3(4.0, 4.0, 4.0)) * _emissionColor.rgb *
                _emissionIntensity;
            o.Emission = emission;

        }
        ENDCG
    }
    FallBack "Diffuse"
}
