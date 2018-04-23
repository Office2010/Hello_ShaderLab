// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Exercises/Diffuse/02_DiffuseVertexLevel"
{
	Properties 
	{
		_Diffuse ("myDiffuse" ,Color ) = (1.0,1.0,1.0,1.0)
	}

	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Diffuse;

			struct a2v 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 color : COLOR;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				// 获取环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// 世界坐标系 法线（NDF）						↓： 法线变换 不需要位移，只取三行三列
				fixed3 worldNormal = normalize( mul(v.normal , (float3x3)unity_WorldToObject) );
				// 世界坐标系 光源（NDF）
				fixed3 worldLight = normalize( _WorldSpaceLightPos0.xyz );

				// 漫反射光 Compute
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate( dot( worldNormal , worldLight ) );

				o.color = ambient + diffuse;

				return o;
			}

			fixed4 frag( v2f i) : SV_Target
			{
				return fixed4(i.color , 1.0);
			}
			ENDCG
		}
	}

	Fallback "Diffuse"
}