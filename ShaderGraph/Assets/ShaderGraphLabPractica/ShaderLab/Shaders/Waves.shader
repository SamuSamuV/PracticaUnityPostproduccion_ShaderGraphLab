Shader "Custom/Waves"
{
    Properties
    {
        _AlbedoA ("Albedo A", 2D) = "white" {}
        _AlbedoB ("Albedo B", 2D) = "white" {}

        _PanDirA ("Pan Direction A", Vector) = (1,0,0,0)
        _PanSpeedA ("Pan Speed A", Range(-10,10)) = 0.25
        _PanDirB ("Pan Direction B", Vector) = (-1,0,0,0)
        _PanSpeedB ("Pan Speed B", Range(-10,10)) = 0.15
        _BlendAB ("Albedo Blend A->B", Range(0,1)) = 0.5

        _WaveDirection ("Wave Direction", Vector) = (1,0,0,0)
        _WaveAmplitude ("Wave Amplitude", Range(0,5)) = 0.2
        _WaveFrequency ("Wave Frequency", Range(0.1,20)) = 2.0
        _WaveSpeed ("Wave Speed", Range(-10,10)) = 1.0

        _HeightIntensity ("Height Color Intensity", Range(0,2)) = 0.5

        _Tiling ("UV Tiling", Vector) = (1,1,0,0)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _AlbedoA;
            sampler2D _AlbedoB;

            float4 _PanDirA;
            float _PanSpeedA;
            float4 _PanDirB;
            float _PanSpeedB;
            float _BlendAB;

            float4 _WaveDirection;
            float _WaveAmplitude;
            float _WaveFrequency;
            float _WaveSpeed;

            float _HeightIntensity;

            float4 _Tiling;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float height : TEXCOORD3;
            };

            float waveAt(float2 posXZ, float2 dir, float freq, float speed, float time)
            {
                float d = dot(posXZ, dir);
                return sin(d * freq + time * speed);
            }

            v2f vert(appdata v)
            {
                v2f o;

                float3 objPos = v.vertex.xyz;
                float2 posXZ = objPos.xz;

                float2 waveDir = normalize((_WaveDirection.xy == float2(0,0)) ? float2(1.0,0.0) : _WaveDirection.xy);
                float t = _Time.y;

                float baseWave = waveAt(posXZ, waveDir, _WaveFrequency, _WaveSpeed, t);
                float displacement = baseWave * _WaveAmplitude;

                float eps = 0.01;
                float dX = waveAt(posXZ + float2(eps,0), waveDir, _WaveFrequency, _WaveSpeed, t) * _WaveAmplitude;
                float dZ = waveAt(posXZ + float2(0,eps), waveDir, _WaveFrequency, _WaveSpeed, t) * _WaveAmplitude;

                float3 n = normalize(v.normal);
                float3 p = objPos + n * displacement;
                float3 pX = objPos + n * dX;
                float3 pZ = objPos + n * dZ;

                float3 tangent = normalize(pX - p);
                float3 bitangent = normalize(pZ - p);
                float3 newNormal = normalize(cross(bitangent, tangent));

                float4 worldPos4 = mul(unity_ObjectToWorld, float4(p,1.0));
                o.worldPos = worldPos4.xyz;
                o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, newNormal));

                o.pos = mul(UNITY_MATRIX_VP, worldPos4);
                o.uv = v.uv * _Tiling.xy;
                o.height = displacement;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 panA = normalize((_PanDirA.xy==float2(0,0))?float2(1,0):_PanDirA.xy) * (_PanSpeedA * _Time.y);
                float2 panB = normalize((_PanDirB.xy==float2(0,0))?float2(1,0):_PanDirB.xy) * (_PanSpeedB * _Time.y);

                float2 uvA = i.uv + panA;
                float2 uvB = i.uv + panB;

                fixed4 colA = tex2D(_AlbedoA, uvA);
                fixed4 colB = tex2D(_AlbedoB, uvB);

                fixed3 baseColor = lerp(colA.rgb, colB.rgb, _BlendAB);

                float heightFactor = saturate((i.height / max(0.0001, _WaveAmplitude)) * 0.5 + 0.5);
                float intensityMul = lerp(1.0 - _HeightIntensity, 1.0 + _HeightIntensity, heightFactor);

                float3 N = normalize(i.worldNormal);
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);

                float3 L;
                float atten = 1.0;

                if (_WorldSpaceLightPos0.w == 0.0)
                {
                    L = normalize(_WorldSpaceLightPos0.xyz);
                }
                else
                {
                    float3 lightPos = _WorldSpaceLightPos0.xyz;
                    L = normalize(lightPos - i.worldPos);
                    float dist = length(lightPos - i.worldPos);
                    atten = 1.0 / max(1.0, dist * dist);
                }

                float NdotL = saturate(dot(N, L));

                float3 lightCol = unity_LightColor[0].rgb;

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * baseColor;
                float3 diffuse = baseColor * lightCol * NdotL * atten;

                float3 final = (ambient + diffuse) * intensityMul;

                return float4(final, 1.0);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}