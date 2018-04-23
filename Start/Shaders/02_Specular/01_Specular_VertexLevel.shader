// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Exercises/Specular/01_Specular_VertexLevel"
{
	Properties
	{
		_Diffuse ("myDiffuse" , Color) = (1,1,1,1)
		_Specular ("mySpecular", Color) = (1,1,1,1)
		//控制高光大小
		_Gloss ("myGloss", Range (8.0 , 256) ) = 20
	}

	SubShader
	{
		Pass
		{
			//该Pass 是光照流水线中， 设置此标签可以使用 内置光照变量 eg： _LightColor0；
			Tags { "LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			// 为了使用内置的变量 如_LightColor0 还需要引用内置文件
			#include "Lighting.cginc"

			//颜色的属性在 0~1 范围中，所以使用 fixed
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};

			v2f vert ( a2v v ) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				//Ambient
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//worldNormal 
				fixed3 worldNormal = normalize( mul(v.normal , (fixed3x3)unity_WorldToObject));
				//worldLightPos
				fixed3 worldLightPos = normalize( _WorldSpaceLightPos0.xyz );

				//Diffuse Half Lambert's law
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (0.6 * dot(worldNormal,worldLightPos) + 0.4);

				//_WorldSpaceLightPos0 得到的是 从顶点到光源方向， But 在计算反射光方向时用的是入射光方向
				//reflectDir
				fixed3 reflectDir = reflect ( -worldLightPos , worldNormal );

				// viewDir  : we need vertex point to camera
				fixed3 viewDir = normalize( _WorldSpaceCameraPos.xyz - mul(v.vertex , unity_WorldToObject).xyz );

				// Specular
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow (saturate (dot (viewDir , reflectDir)) ,_Gloss);

				o.color = ambient + diffuse + specular;	
				return o;
			}

			fixed4 frag ( v2f i) : SV_Target
			{
				return fixed4(i.color ,1.0);
			}
			ENDCG
		}
	}

	Fallback "Diffuse"
}