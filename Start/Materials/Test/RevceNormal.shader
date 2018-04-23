// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Exercises/Test/ReversNormal"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white"{}
	}

	SubShader
	{
		Tags{"LightMode" = "ForwardBase"}
		Pass
		{
			Cull front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : texcoord0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv: texcoord2;
			};

			v2f vert( a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos( v.vertex);
								
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				o.worldPos = mul(unity_ObjectToWorld , v.vertex).xyz;

				o.uv = TRANSFORM_TEX(v.texcoord , _MainTex);
				return o;
			}

			fixed4 frag(v2f i ):SV_Target
			{
				fixed3 worldNormal = normalize (i.worldNormal);
				fixed3 worldLightDir = normalize ( UnityWorldSpaceLightDir(i.worldPos));

				fixed4 tintColor = tex2D (_MainTex , i.uv);

				fixed3 diffuse = _LightColor0.rgb *tintColor.rgb* saturate( dot( worldNormal,-worldLightDir));

				return fixed4(tintColor.rgb,1.0);
			}
			ENDCG
		}
	}

	Fallback "Diffuse"
}