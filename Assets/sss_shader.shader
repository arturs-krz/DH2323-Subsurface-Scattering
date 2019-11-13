Shader "Custom/SubsurfaceScatteringShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,0,0,1)
        _MainTex ("Albedo (RGB)", 2D) = "red" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

		float4x4 _DepthCamV;
		float4x4 _DepthCamP;
		sampler2D _DepthTexz;
		float4 _DepthTexz_ST;

        struct Input
        {
            float2 uv_MainTex;
			float exitDist;
			float4 depthMapPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			float4x4 MVP = mul(_DepthCamP, mul(_DepthCamV, unity_ObjectToWorld));
			float4 lightPoint = mul(MVP, v.vertex);
			o.exitDist = length(lightPoint.xyz);
			o.depthMapPos = ComputeScreenPos(lightPoint);
		}

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			float d_i = tex2Dproj(_DepthTexz, IN.depthMapPos).x;
			float d_o = 1.0 - clamp(IN.exitDist / 20.0, 0, 1);
			float si = (d_i - d_o) * 7.0;

            // Albedo comes from a texture tinted by color
			//fixed4 subsurf = exp(-si * 1) * _Color;
			//fixed4 c = fixed4(d_i, 0.5 - d_i, 0, 1);
			fixed4 c = fixed4(si, 0.5 - si, 0, 1);
			
			//fixed4 c = exp(-si * 2) * fixed4(1, 0, 0, 1);
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
