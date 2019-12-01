Shader "Custom/SubsurfaceScatteringShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,0,0,1)
        _MainTex ("Albedo (RGB)", 2D) = "red" {}
		_EmissionTex("Emission (RGB)", 2D) = "red" {}
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

		sampler2D _EmissionTex;
		float4 _EmissionTex_ST;

        struct Input
        {
            float2 uv_MainTex;
			float exitDist;
			float4 depthMapPos;
			float3 lightDir;
			float3 viewDir; // view direction (to the main cam)
			float3 worldNormal;
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
			o.lightDir = -lightPoint.xyz;
			o.exitDist = length(lightPoint.xyz) / 15.0;
			o.depthMapPos = ComputeScreenPos(lightPoint);
		}

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			float d_i = 0.0;
			float ray_blur = 0.02;


			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x - (2 * ray_blur), IN.depthMapPos.y + (2 * ray_blur), IN.depthMapPos.zw)).x * 0.003765;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x - (2 * ray_blur), IN.depthMapPos.y + ray_blur, IN.depthMapPos.zw)).x * 0.015019;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x - (2 * ray_blur), IN.depthMapPos.y, IN.depthMapPos.zw)).x * 0.023792;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x - (2 * ray_blur), IN.depthMapPos.y - ray_blur, IN.depthMapPos.zw)).x * 0.015019;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x - (2 * ray_blur), IN.depthMapPos.y - (2 * ray_blur), IN.depthMapPos.zw)).x * 0.003765;

			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x - ray_blur, IN.depthMapPos.y + (2 * ray_blur), IN.depthMapPos.zw)).x * 0.015019;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x - ray_blur, IN.depthMapPos.y + ray_blur, IN.depthMapPos.zw)).x * 0.059912;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x - ray_blur, IN.depthMapPos.y, IN.depthMapPos.zw)).x * 0.094907;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x - ray_blur, IN.depthMapPos.y - ray_blur, IN.depthMapPos.zw)).x * 0.059912;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x - ray_blur, IN.depthMapPos.y - (2 * ray_blur), IN.depthMapPos.zw)).x * 0.015019;

			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x, IN.depthMapPos.y + (2 * ray_blur), IN.depthMapPos.zw)).x * 0.023792;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x, IN.depthMapPos.y + ray_blur, IN.depthMapPos.zw)).x * 0.094907;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x, IN.depthMapPos.y, IN.depthMapPos.zw)).x * 0.150342;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x, IN.depthMapPos.y - ray_blur, IN.depthMapPos.zw)).x * 0.094907;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x, IN.depthMapPos.y - (2 * ray_blur), IN.depthMapPos.zw)).x * 0.023792;

			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x + ray_blur, IN.depthMapPos.y + (2 * ray_blur), IN.depthMapPos.zw)).x * 0.015019;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x + ray_blur, IN.depthMapPos.y + ray_blur, IN.depthMapPos.zw)).x * 0.059912;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x + ray_blur, IN.depthMapPos.y, IN.depthMapPos.zw)).x * 0.094907;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x + ray_blur, IN.depthMapPos.y - ray_blur, IN.depthMapPos.zw)).x * 0.059912;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x + ray_blur, IN.depthMapPos.y - (2 * ray_blur), IN.depthMapPos.zw)).x * 0.015019;

			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x + (2 * ray_blur), IN.depthMapPos.y + (2 * ray_blur), IN.depthMapPos.zw)).x * 0.003765;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x + (2 * ray_blur), IN.depthMapPos.y + ray_blur, IN.depthMapPos.zw)).x * 0.015019;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x + (2 * ray_blur), IN.depthMapPos.y, IN.depthMapPos.zw)).x * 0.023792;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x + (2 * ray_blur), IN.depthMapPos.y - ray_blur, IN.depthMapPos.zw)).x * 0.015019;
			d_i += tex2Dproj(_DepthTexz, float4(IN.depthMapPos.x + (2 * ray_blur), IN.depthMapPos.y - (2 * ray_blur), IN.depthMapPos.zw)).x * 0.003765;


			//float3 entryMap = tex2Dproj(_DepthTexz, IN.depthMapPos).xyz;
			//float d_i = tex2Dproj(_DepthTexz, IN.depthMapPos).x;
			//float d_o = 1.0 - clamp(IN.exitDist / 5.0, 0.0, 1.0);
			float d_o = IN.exitDist;
			float si = clamp((d_o - d_i), 0.0, 1.0);
			//float si = clamp(2.0 * ((d_o / d_i) - 1.0), 0.0, 1.0);
			
			float H = normalize(IN.lightDir + IN.worldNormal * 0.8);
			float I = pow(saturate(dot(IN.viewDir, -H)), 2) * 2;

            // Albedo comes from a texture tinted by color
			//fixed4 subsurf = exp(-si * 1) * _Color;
			// c = fixed4(d_i, 0, 1.0 - d_i, 1);
			//fixed4 c = fixed4(exp(-si * 2) * 1, exp(-si * 5) * 0.8, 0, 1);
			
			//fixed4 c = tex2D(_MainTex, float2(d_o - d_i, 0.5));
			//fixed4 c = tex2D(_MainTex, float2(si, 0.5));

			float tex_blur = 0.002;
			fixed4 c = fixed4(0, 0, 0, 1);
			c.rgb += tex2D(_MainTex, float2(si - (2 * tex_blur), 0.5)).rgb * 0.06136;
			c.rgb += tex2D(_MainTex, float2(si - tex_blur, 0.5)).rgb * 0.24477;
			c.rgb += tex2D(_MainTex, float2(si, 0.5)).rgb * 0.38774;
			c.rgb += tex2D(_MainTex, float2(si + tex_blur, 0.5)).rgb * 0.24477;
			c.rgb += tex2D(_MainTex, float2(si + (2* tex_blur), 0.5)).rgb * 0.06136;

			float emission_blur = 0.08;
			fixed4 e = fixed4(0, 0, 0, 1);
			e.rgb += tex2D(_EmissionTex, float2(si - (2 * emission_blur), 0.5)).rgb * 0.06136;
			e.rgb += tex2D(_EmissionTex, float2(si - emission_blur, 0.5)).rgb * 0.24477;
			e.rgb += tex2D(_EmissionTex, float2(si, 0.5)).rgb * 0.38774;
			e.rgb += tex2D(_EmissionTex, float2(si + emission_blur, 0.5)).rgb * 0.24477;
			e.rgb += tex2D(_EmissionTex, float2(si + (2 * emission_blur), 0.5)).rgb * 0.06136;
			
			//fixed4 c = exp(-si * 2) * fixed4(1, 0, 0, 1);
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
			o.Emission = I * e;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
