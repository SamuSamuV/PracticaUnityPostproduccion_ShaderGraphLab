Shader "Custom/Cutoff4"
{
    Properties
    {
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
            float3 worldPos;
        };

        float4 _color1, _color2;
        half _patternScale, _color2Size;

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Emission = frac((IN.worldPos.x + IN.worldPos.y) * _patternScale) > _color2Size ? _color1.rgb : _color2.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
