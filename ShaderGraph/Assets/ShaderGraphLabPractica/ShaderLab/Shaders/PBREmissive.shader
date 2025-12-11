Shader "Custom/PBREmissive"
{
    Properties
    {
        _albedoTexture ("Albedo Texture", 2D) = "white" {}
        _normalTexture ("Normal Texture", 2D) = "bump" {}
        _normalIntensity ("Normal Intensity", Range(0, 1)) = 1.0

        _smoothnessTexture ("Smoothness Texture", 2D) = "white" {}
        _smoothness ("Smoothness (base)", Range(0,1)) = 0.5
        _smoothnessIntensity ("Smoothness Intensity (blend)", Range(0,1)) = 1.0

        _metallicTexture ("Metallic Texture", 2D) = "white" {}
        _metallic ("Metallic (base)", Range(0,1)) = 0.0
        _metallicIntensity ("Metallic Intensity (blend)", Range(0,1)) = 1.0

        _emissionTexture ("Emission Texture", 2D) = "black" {}
        _emissionIntensity ("Emission Intensity", Range(0,2)) = 0.5
        _emissionColor ("Emission Color", Color) = (0,0,0,1)

        _AOTexture ("Ambient Occlusion Texture", 2D) = "white" {}
        _AOIntensity ("Ambient Occlusion Intensity", Range(0, 1)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        struct Input {
            float2 uv_albedoTexture;
            float2 uv_normalTexture;
            float2 uv_smoothnessTexture;
            float2 uv_metallicTexture;
            float2 uv_emissionTexture;
        };

        sampler2D _albedoTexture;
        sampler2D _normalTexture;
        sampler2D _smoothnessTexture;
        sampler2D _metallicTexture;
        sampler2D _emissionTexture;
        sampler2D _AOTexture;

        float _normalIntensity;
        float _smoothness;
        float _smoothnessIntensity;
        float _metallic;
        float _metallicIntensity;
        float _emissionIntensity;
        float _AOIntensity;
        float4 _emissionColor;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float3 albedo = tex2D(_albedoTexture, IN.uv_albedoTexture).rgb;
            o.Albedo = albedo;

            float metallicFromTex = tex2D(_metallicTexture, IN.uv_metallicTexture).r;
            o.Metallic = lerp(_metallic, metallicFromTex, saturate(_metallicIntensity));

            float smoothnessFromTex = tex2D(_smoothnessTexture, IN.uv_smoothnessTexture).r;
            o.Smoothness = lerp(_smoothness, smoothnessFromTex, saturate(_smoothnessIntensity));

            float3 normalTex = UnpackNormal(tex2D(_normalTexture, IN.uv_normalTexture));
            float3 flatNormal = float3(0, 0, 1);
            o.Normal = normalize(lerp(flatNormal, normalTex, saturate(_normalIntensity)));

            float3 emissionTex = tex2D(_emissionTexture, IN.uv_emissionTexture).rgb;
            float emissionGray = dot(emissionTex, float3(0.299, 0.587, 0.114));
            o.Emission = emissionGray * _emissionColor.rgb * _emissionIntensity;

            float ao = tex2D(_AOTexture, IN.uv_albedoTexture).r;
            o.Occlusion = saturate(ao * _AOIntensity);
        }
        ENDCG
    }

    FallBack "Diffuse"
}