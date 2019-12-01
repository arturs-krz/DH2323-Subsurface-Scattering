Shader "Unlit/DepthShader"
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

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				// make fog work
				#pragma multi_compile_fog

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float3 normal : NORMAL;
				};

				struct v2f
				{
					//float2 uv : TEXCOORD0;
					float dist : TEXCOORD1;
					//UNITY_FOG_COORDS(1)
					float4 vertex : SV_POSITION;
				};

				float4x4 _DepthCamV;
				float4x4 _DepthCamP;

				v2f vert(appdata v)
				{
					//float4x4 MVP = mul(_DepthCamP, mul(_DepthCamV, unity_ObjectToWorld));
					float4x4 MVP = mul(_DepthCamP, mul(_DepthCamV, unity_ObjectToWorld));
					v2f o;
					o.dist = length(mul(MVP, v.vertex).xyz) / 15.0;

					float4 vert = v.vertex;
					vert.xyz += v.normal * 0.2;
					o.vertex = UnityObjectToClipPos(vert);
					//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					//UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				float4 frag(v2f i) : SV_Target
				{
					//return float4(1.0 - clamp(i.dist / 5.0, 0.0, 1.0), 0, 0, 1);
					//return float4(i.dist, i.dist / 10.0, i.dist / 100.0, 1);
					return float4(i.dist, 0, 0, 1);
				}
			//}
			ENDCG
			}
		//Fallback "Diffuse"
		}
}
