Shader "Custom/Toon"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1,1,1,1)

        _RampTex ("Ramp Texture (1D)", 2D) = "gray" {}
        _RampIntensity ("Ramp Intensity", Range(0,2)) = 1.0

        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _OutlineWidth ("Outline Width", Range(0,0.1)) = 0.02

        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            Name "OUTLINE"
            Tags { "LightMode" = "Always" }
            Cull Front
            ZWrite On

            CGPROGRAM
            #pragma vertex vertOutline
            #pragma fragment fragOutline
            #pragma target 3.0
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _OutlineColor;
            float _OutlineWidth;
            float4 _Color;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vertOutline(appdata v)
            {
                v2f o;
                float3 n = normalize(v.normal);
                float3 offset = n * _OutlineWidth;
                float4 displaced = float4(v.vertex.xyz + offset, 1.0);
                o.pos = UnityObjectToClipPos(displaced);
                return o;
            }

            fixed4 fragOutline(v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }

        CGPROGRAM
        #pragma surface surf ToonRamp addshadow fullforwardshadows alpha:fade
        #pragma target 3.0
        #include "UnityCG.cginc"
        #include "Lighting.cginc"

        sampler2D _MainTex;
        fixed4 _Color;

        sampler2D _RampTex;
        float _RampIntensity;

        float _Cutoff;

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = tex.rgb * _Color.rgb;
            o.Alpha = tex.a * _Color.a;

            clip(o.Alpha - _Cutoff);
        }

        half4 LightingToonRamp (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
        {
            half NdotL = saturate(dot(s.Normal, lightDir));
            half rampSample = tex2D(_RampTex, float2(NdotL, 0.5)).r;
            rampSample = saturate(rampSample * _RampIntensity);

            half3 lightColor = _LightColor0.rgb;
            half3 diffuse = s.Albedo * lightColor * rampSample * atten;

            half3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * s.Albedo * 0.5;

            return half4(diffuse + ambient, 1.0);
        }

        ENDCG
    }

    FallBack "Diffuse"
}