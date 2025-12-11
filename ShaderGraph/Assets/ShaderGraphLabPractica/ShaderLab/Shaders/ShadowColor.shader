Shader "Custom/ShadowColor"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _NormalTex ("Normal Map", 2D) = "bump" {}
        _ShadowColor ("Shadow Color", Color) = (0,0,0,1)
        _ShadowStrength ("Shadow Strength", Range(0,1)) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        LOD 300

        Pass
        {
            Name "ForwardBase"
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_shadowcaster
            #pragma target 3.0

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NormalTex;

            float4 _ShadowColor;
            float _ShadowStrength;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;

                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;

                float3 tangentWorld : TEXCOORD3;
                float3 bitangentWorld : TEXCOORD4;

                SHADOW_COORDS(5)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float3 wNormal = UnityObjectToWorldNormal(v.normal);
                float3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 wBitangent = cross(wNormal, wTangent) * v.tangent.w;

                o.worldNormal = wNormal;
                o.tangentWorld = wTangent;
                o.bitangentWorld = wBitangent;

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 normal;

                float3 normalMap = UnpackNormal(tex2D(_NormalTex, i.uv));
                normal = normalize(
                    normalMap.x * i.tangentWorld +
                    normalMap.y * i.bitangentWorld +
                    normalMap.z * i.worldNormal
                );

                float ndotl = saturate(dot(normal, lightDir));

                float shadowAtt = SHADOW_ATTENUATION(i);

                float3 albedo = tex2D(_MainTex, i.uv).rgb;

                float3 litColor = albedo * ndotl;

                float shadowFactor = (1.0 - shadowAtt) * _ShadowStrength;
                float3 coloredShadow = _ShadowColor.rgb * shadowFactor;

                float3 finalColor = lerp(litColor, coloredShadow, shadowFactor);

                return float4(finalColor, 1);
            }
            ENDCG
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f { float4 pos : SV_POSITION; };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                return 0;
            }
            ENDCG
        }
    }
}