Shader "Custom/Hologram"
{
    Properties
    {
        _rimColor ("Rim Color", Color) = (0.5, 0, 0, 0)
        _rimPower ("Rim Power", Range(0, 10)) = 1.0
        _rimIntensity ("Rim Intensity", Range(0, 5)) = 1.0
        _flickeringSpeed ("Flickering Speed", Range(0, 20)) = 0.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }

        CGPROGRAM
        #pragma surface surf Lambert alpha:fade

        struct Input
        {
            float3 viewDir;
        };

        float4 _rimColor;
        half _rimPower, _rimIntensity, _flickeringSpeed;

        void surf (Input IN, inout SurfaceOutput o)
        {
            half rim = 1.0 - dot(normalize(IN.viewDir), o.Normal);
            half rimPower = pow(rim, (sin(_Time.z * _flickeringSpeed) + 2.0) * 0.25 * _rimPower);
            o.Emission = rimPower * _rimColor * (cos(_Time.z * _flickeringSpeed * 2.0) + 2.0) * 0.25 * _rimIntensity;
            o.Alpha = rimPower;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
