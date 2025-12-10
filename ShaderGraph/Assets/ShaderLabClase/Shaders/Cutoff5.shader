Shader "Custom/Cutoff5"
{
    Properties
    {
        _mainTexture ("Main Texture", 2D) = "white" {}
        _color1 ("Color 1", Color) = (1, 0, 0, 1)
        _color2 ("Color 2", Color) = (0, 0, 1, 1)
        _patternScale ("Pattern Scale", Range(0, 10)) = 5.0
        _color2Size ("Color 2 Size", Range(0, 1)) = 0.5
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        struct Input
        {
            float2 uv_mainTexture;
            float3 viewDir;
            float3 worldPos;
        };

        sampler2D _mainTexture;
        float4 _color1, _color2;
        half _patternScale, _color2Size;

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D(_mainTexture, IN.uv_mainTexture).rgb;

            half rim = 1 - saturate(dot(normalize(IN.viewDir), o.Normal));
            float3 strips = frac(IN.worldPos.x * _patternScale) > _color2Size ? _color1.rgb : _color2.rgb;
            o.Emission = strips * rim;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
