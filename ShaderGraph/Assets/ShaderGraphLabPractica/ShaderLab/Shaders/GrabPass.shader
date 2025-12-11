Shader "Custom/GrabPass"
{
    Properties
    {
        _MainTint ("Main Tint", Color) = (1,1,1,0.5)
        _MainTex ("Albedo (not required)", 2D) = "white" {}
        _NormalTex ("Refraction Normal Map", 2D) = "bump" {}
        _RefractionStrength ("Refraction Strength", Range(0,0.2)) = 0.03
        _ChromaticDispersion ("Chromatic Dispersion", Range(0,0.1)) = 0.015
        _FresnelPower ("Fresnel Power", Range(0.1,8)) = 2.0
        _GrabTint ("Grab Tint", Color) = (1,1,1,1)
        _Opacity ("Opacity", Range(0,1)) = 1.0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        GrabPass { "_GrabTexture" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _NormalTex;
            sampler2D _GrabTexture;

            float4 _MainTint;
            float4 _GrabTint;
            float _RefractionStrength;
            float _ChromaticDispersion;
            float _FresnelPower;
            float _Opacity;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float4 grabPos : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.grabPos = ComputeGrabScreenPos(o.pos);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(_WorldSpaceCameraPos - worldPos);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 grabUV = i.grabPos.xy / i.grabPos.w;
                #if UNITY_UV_STARTS_AT_TOP
                grabUV.y = 1.0 - grabUV.y;
                #endif

                float3 n = UnpackNormal(tex2D(_NormalTex, i.uv)).xyz * 2.0 - 1.0;
                n = normalize(mul((float3x3)unity_ObjectToWorld, n));

                float3 viewDir = normalize(i.viewDir);
                float fresnel = pow(1.0 - saturate(dot(viewDir, n)), _FresnelPower);

                float2 offset = n.xy * _RefractionStrength;
                float2 offR = offset * (1.0 + _ChromaticDispersion);
                float2 offG = offset;
                float2 offB = offset * (1.0 - _ChromaticDispersion);

                float3 grabR = tex2D(_GrabTexture, grabUV + offR).rgb;
                float3 grabG = tex2D(_GrabTexture, grabUV + offG).rgb;
                float3 grabB = tex2D(_GrabTexture, grabUV + offB).rgb;
                float3 grabbed = float3(grabR.r, grabG.g, grabB.b);

                grabbed *= _GrabTint.rgb;

                float3 baseCol = _MainTint.rgb;
                float3 finalRefract = lerp(baseCol, grabbed, fresnel);

                float alpha = _Opacity * _MainTint.a;
                return float4(finalRefract, alpha);
            }
            ENDCG
        }
    }

    FallBack "Transparent/Diffuse"
}