Shader "Custom/TexturesBlending"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _DecalTex ("Decal Texture", 2D) = "white" {}
        [Toggle] _ShowDecal ("Show Decal", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows

        sampler2D _MainTex, _DecalTex;
        float _ShowDecal;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_DecalTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            fixed4 d = tex2D (_DecalTex, IN.uv_DecalTex) * _ShowDecal;
            o.Albedo = length(d.rgb) > 0.5 ? d.rgb : c.rgb;

        }
        ENDCG
    }
    FallBack "Diffuse"
}
