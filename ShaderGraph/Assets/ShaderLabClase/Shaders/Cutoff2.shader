Shader "Custom/Cutoff2"
{
    Properties
    {
        _rimColorOutside ("Rim Color Outside", Color) = (1, 1, 1, 1)
        _rimColorMiddle ("Rim Color Middle", Color) = (0, 0, 0, 1)
        _rimColorInside ("Rim Color Inside", Color) = (0, 0, 0, 1)
        _rimPower ("Rim Power", Range(0, 10)) = 1.0
        _rimSize  ("Rim Size", Range(0, 1)) = 0.5
        _rimSizeInner  ("Rim Size Inner", Range(0, 1)) = 0.5
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        struct Input
        {
            float3 viewDir;
        };

        float4 _rimColorOutside, _rimColorMiddle, _rimColorInside;
        float _rimPower, _rimSize, _rimSizeInner;

        void surf (Input IN, inout SurfaceOutput o)
        {
            half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
            o.Emission = rim > _rimSize ? _rimColorOutside.rgb : rim > _rimSize * _rimSizeInner ? _rimColorMiddle.rgb : _rimColorInside;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
