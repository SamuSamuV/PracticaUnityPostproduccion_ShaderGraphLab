Shader "Custom/Rim"
{
    Properties
    {
        _rimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _rimIntensity ("Rim Intensity", Range(0, 10)) = 1.0
        _rimPower ("Rim Power", Range(0, 10)) = 1.0
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        struct Input
        {
            float3 viewDir;
        };

        float4 _rimColor;
        float _rimPower, _rimIntensity;

        void surf (Input IN, inout SurfaceOutput o)
        {
            float rim = 1.0 - saturate(dot(IN.viewDir, o.Normal));
            rim = pow(rim, _rimPower);
            o.Emission = _rimColor.rgb * rim * _rimIntensity;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
