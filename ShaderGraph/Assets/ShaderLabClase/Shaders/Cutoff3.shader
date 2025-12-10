Shader "Custom/Cutoff3"
{
    Properties
    {
        _color1 ("Color 1", Color) = (1, 0, 0, 1)
        _color2 ("Color 2", Color) = (0, 0, 1, 1)
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

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Emission = IN.worldPos.y > 1 ? _color1.rgb : _color2.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
