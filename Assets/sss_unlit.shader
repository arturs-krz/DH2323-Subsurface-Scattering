Shader "Unlit/sss_unlit"
{
    Properties
    {
		_Color("Color", Color) = (1,0,0,1)
		_MainTex("Albedo (RGB)", 2D) = "red" {}
		_DepthTex("Depth texture", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

   //     Pass
   //     {
   //         CGPROGRAM
   //         #pragma vertex vert
   //         #pragma fragment frag
   //         // make fog work
   //         #pragma multi_compile_fog

   //         #include "UnityCG.cginc"

   //         struct appdata
   //         {
   //             float4 vertex : POSITION;
   //             float2 uv : TEXCOORD0;
   //         };

   //         struct v2f
   //         {
   //             float2 uv : TEXCOORD0;
			//	float dLight : TEXCOORD1;
			//	UNITY_FOG_COORDS(1)
   //             float4 vertex : SV_POSITION;
   //         };

   //         sampler2D _MainTex;
   //         float4 _MainTex_ST;

			//float4x4 _LightV;
			//float4x4 _LightMVP;
			//float4x4 _LightMV;
			//float4x4 _LightMatrix;

   //         v2f vert (appdata v)
   //         {
   //             v2f o;
			//	o.dLight = length(mul(_LightMV, v.vertex).xyz);
   //             o.vertex = UnityObjectToClipPos(v.vertex);
   //             o.uv = TRANSFORM_TEX(v.uv, _MainTex);
   //             UNITY_TRANSFER_FOG(o,o.vertex);
   //             return o;
   //         }

   //         fixed4 frag (v2f i) : SV_Target
   //         {
   //             //// sample the texture
   //             fixed4 col = tex2D(_MainTex, i.uv);
   //             //// apply fog
   //             //UNITY_APPLY_FOG(i.fogCoord, col);
   //             //return col;

			//	//float4 PointInLightSpace = mul(_Object2Light0[0], i.vertex);

			//	// transform point into light texture space

			//	//float4 texCoord = mul(_LightMVP, i.vertex);
			//	//float4 texCoord = mul(_LightMatrix, PointInLightSpace);

			//	// get distance from light at entry point

			//	//float d_i = tex2Dproj(_DepthTex, texCoord);
			//	//float d_i = tex2D(_DepthTex, texCoord.xy).x;
			//	
			//	//float d_i = i.dist.x;
			//	//float d_i = Linear01Depth(i.dist, i.hpos);

			//	// transform position to light space

			//	//float4 Plight = mul(_LightV, i.vertex);

			//	// distance of this pixel from light (exit)

			//	//float d_o = length(Plight);

			//	// calculate depth

			//	//float s = (d_o - d_i) / 1000;

			//	//return fixed4(s, 1 - s, 0, 1);
			//	//return col;
			//	//return tex2D(_DepthTex, i.uv);
			//	//return fixed4(0, 1, 0, 1);
			//	//return tex2D(_DepthTex, i.uv);

			//	//return fixed4(i.uv, 0, 1);
			//	
			//	//return fixed4(clamp(d_i, 0, 1), 0, 0, 1);
			//	//return fixed4(1.0 - clamp(i.dLight / 50, 0, 1), 0, 0, 1);
			//	return fixed4(1, 1, 0, 1);
			//	//return exp(-s * 1) * fixed4(1, 0, 0, 1);
   //         }
   //         ENDCG
   //     }

		Pass
		{
		// Depth pass
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;

			// Light (camera) MV and MVP matrices set in script
			//float4x4 _LightMV;
			//float4x4 _LightMVP;

			//float4x4 _LightMatrix;

			float4x4 _DepthCamV;
			float4x4 _DepthCamP;
			sampler2D _DepthTexz;
			float4 _DepthTexz_ST;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				//float4 vertex : POSITION;
				//float4 hpos : POSITION;
				//float2 dist : TEXCOORD0;
				float2 uv : TEXCOORD0;
				float4 entryPoint : TEXCOORD1;
				float exitDist : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				float4x4 MVP = mul(_DepthCamP, mul(_DepthCamV, unity_ObjectToWorld));
				float4 lightPoint = mul(MVP, v.vertex);
				o.exitDist = length(lightPoint.xyz);
				o.entryPoint = lightPoint;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.screenPos = ComputeScreenPos(lightPoint);
				UNITY_TRANSFER_FOG(o, o.vertex);
				//OUT.vertex = v.vertex;
				//float4 P = v.vertex;
				//P.xyz += v.normal * 0; // grow = 10
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				//fixed4 depthMap = fixed4(i.dist, 0, 0);
				//eturn dist;
				//float4 texCoord = mul(_LightMVP, i.vertex);

				//return tex2D(_DepthTexz, i.uv);
				float d_i = tex2Dproj(_DepthTexz, i.screenPos).x;
				float d_o = 1.0 - clamp(i.exitDist / 50, 0, 1);
				float si = (d_i - d_o) * 10.0;

				//return fixed4(d_i.x, 0, 0, 1);
				return exp(-si * 1) * float4(0.8, 0, 0, 1);
			}

			ENDCG
		}
    }

	Fallback "Diffuse"
}
