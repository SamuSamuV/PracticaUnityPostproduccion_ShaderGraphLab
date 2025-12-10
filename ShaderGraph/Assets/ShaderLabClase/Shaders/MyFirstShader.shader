Shader "Custom/MyFirstShader"
{
    Properties
    {
        _myColor ("Main Color", Color) = (1,1,1,1)
        _emissiveColor ("Emissive Color", Color) = (0,0,0,1)
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        struct Input {
            float2 uvMainTex;
        };

        float4 _myColor, _emissiveColor;
        
        void surf (Input IN, inout SurfaceOutput o){
            o.Albedo = _myColor.rgb;
            o.Emission = _emissiveColor.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
