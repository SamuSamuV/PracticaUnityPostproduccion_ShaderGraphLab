Shader "Custom/PBRRim"
{
    Properties
    {
        _AlbedoTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalTex ("Normal (normalmap)", 2D) = "bump" {}
        _MetallicTex ("Metallic (R)", 2D) = "white" {}
        _RoughnessTex ("Roughness (R)", 2D) = "white" {}
        _AOTexture ("Ambient Occlusion (R)", 2D) = "white" {}

        _MetallicBase ("Metallic (base)", Range(0,1)) = 0.0
        _MetallicIntensity ("Metallic Intensity (blend)", Range(0,1)) = 1.0

        _SmoothnessBase ("Smoothness (base)", Range(0,1)) = 0.5
        _SmoothnessIntensity ("Smoothness Intensity (blend)", Range(0,1)) = 1.0

        _AOBase ("AO (base)", Range(0,1)) = 1.0
        _AOIntensity ("AO Intensity (blend)", Range(0,1)) = 1.0

        _NormalIntensity ("Normal Intensity", Range(0,1)) = 1.0

        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimIntensity ("Rim Intensity", Range(0,20)) = 0.5
        _RimPower ("Rim Power (curve)", Range(0,20)) = 2.0
        _RimThreshold ("Rim Threshold (min dot)", Range(0,1)) = 0.0

        _EmissionColor ("Emission Color", Color) = (0,0,0,1)
        _EmissionIntensity ("Emission Intensity", Range(0,4)) = 0.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        struct Input {
            float2 uv_AlbedoTex;
            float2 uv_NormalTex;
            float2 uv_MetallicTex;
            float2 uv_RoughnessTex;
            float2 uv_AOTexture;
            float3 worldPos;
        };

        sampler2D _AlbedoTex;
        sampler2D _NormalTex;
        sampler2D _MetallicTex;
        sampler2D _RoughnessTex;
        sampler2D _AOTexture;

        float _MetallicBase;
        float _MetallicIntensity;

        float _SmoothnessBase;
        float _SmoothnessIntensity;

        float _AOBase;
        float _AOIntensity;

        float _NormalIntensity;

        fixed4 _RimColor;
        float _RimIntensity;
        float _RimPower;
        float _RimThreshold;

        fixed4 _EmissionColor;
        float _EmissionIntensity;

        inline float3 GetViewDirWorld(float3 worldPos)
        {
            return normalize(UnityWorldSpaceViewDir(worldPos));
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float3 albedo = tex2D(_AlbedoTex, IN.uv_AlbedoTex).rgb;
            o.Albedo = albedo;

            float metallicFromTex = tex2D(_MetallicTex, IN.uv_MetallicTex).r;
            o.Metallic = lerp(_MetallicBase, metallicFromTex, saturate(_MetallicIntensity));

            float roughnessFromTex = tex2D(_RoughnessTex, IN.uv_RoughnessTex).r;
            float smoothnessFromTex = 1.0 - roughnessFromTex;
            o.Smoothness = lerp(_SmoothnessBase, smoothnessFromTex, saturate(_SmoothnessIntensity));
            o.Smoothness = saturate(o.Smoothness);

            float aoFromTex = tex2D(_AOTexture, IN.uv_AOTexture).r;
            float ao = lerp(_AOBase, aoFromTex, saturate(_AOIntensity));
            o.Occlusion = saturate(ao);

            float3 normalTex = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
            float3 flatNormal = float3(0,0,1);
            float3 blendedNormal = normalize(lerp(flatNormal, normalTex, saturate(_NormalIntensity)));
            o.Normal = blendedNormal;

            float3 emissionBase = _EmissionColor.rgb * _EmissionIntensity;
            o.Emission = emissionBase;

            float3 viewDir = GetViewDirWorld(IN.worldPos);
            float ndotV = saturate(dot(o.Normal, viewDir));
            float rimFactor = pow(saturate(1.0 - ndotV), max(0.0001, _RimPower));
            rimFactor = rimFactor * step(_RimThreshold, rimFactor);
            float3 rimContribution = rimFactor * _RimIntensity * _RimColor.rgb;
            o.Emission += rimContribution;
        }
        ENDCG
    }

    FallBack "Diffuse"
}