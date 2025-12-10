Shader "Custom/Cutoff1"
{
    Properties
    {
        _rimColorOutside ("Rim Color Outside", Color) = (1, 1, 1, 1)
        _rimColorInside ("Rim Color Inside", Color) = (0, 0, 0, 1)
        _rimPower ("Rim Power", Range(0, 10)) = 1.0
        _rimSize  ("Rim Size", Range(0, 1)) = 0.5
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        struct Input
        {
            float3 viewDir;
        };

        float4 _rimColorOutside, _rimColorInside;
        float _rimPower, _rimSize;

        void surf (Input IN, inout SurfaceOutput o)
        {
            half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
            o.Emission = rim > _rimSize ? _rimColorInside.rgb : _rimColorOutside.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
