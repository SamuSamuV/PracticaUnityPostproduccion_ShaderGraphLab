Shader "Unlit/VertexFragmentExtrude"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Extrude ("Extrude", Range(-0.2, 0.2)) = 0
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert vertex:vert addshadow

        struct appdata
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };

        struct Input
        {
            float2 uv_MainTex;
        };

        sampler2D _MainTex;
        float _Extrude;

        void vert (inout appdata v)
        {
            v.vertex.xyz += v.normal * _Extrude;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
        }
        ENDCG
    }
    Fallback "Diffuse"
}
