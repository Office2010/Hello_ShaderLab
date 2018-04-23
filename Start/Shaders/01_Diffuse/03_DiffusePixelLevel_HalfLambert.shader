// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Exercises/Diffuse/03_DiffusePixelLevel_HalfLambert" 
{
	Properties
	{
		_Diffuse ("myDiffuse" , Color) = (1.0,1.0,1.0,1.0)
	}

	SubShader
	{
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			float4 _Diffuse;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
			};

			v2f vert( a2v i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);

				o.worldNormal = mul( i.normal,(float3x3)unity_WorldToObject);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 lightPos = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb *(0.6 * dot(worldNormal,lightPos) + 0.4);

				fixed3 color = ambient + diffuse;
				return fixed4(color,1.0);
			}
			ENDCG
		}
	}

	Fallback "Diffuse"
}
