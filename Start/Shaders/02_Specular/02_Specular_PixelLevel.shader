// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Exercises/Specular/02_SpecularPixelLevel"
{
	Properties
	{
		_Diffuse ("myDiffuse" , Color) = (1,1,1,1)
		_Specular ("mySpecular" , Color) = (1,1,1,1)
		_Gloss ("myGloss" , Range(8.0, 255)) = 20
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
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				fixed3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
				fixed3 worldVertex : TEXCOORD1;
			};

			v2f vert ( a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos( v.vertex);

				o.worldNormal = normalize ( mul (v.normal, unity_WorldToObject) );
				o.worldVertex = mul( v.vertex , unity_WorldToObject).xyz;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//Ambient
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = i.worldNormal;
				fixed3 worldLightPos = normalize( _WorldSpaceLightPos0.xyz);

				//Diffuse Half lambert's law
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (0.6 * dot ( worldNormal,worldLightPos) + 0.4);

				//reflect  light direct : we need light point to point
				fixed3 reflectDir = reflect (-worldLightPos , worldNormal);

				//viewDir   : we need vertex point to camera
				fixed3 viewDir = normalize( _WorldSpaceCameraPos.xyz - i.worldVertex.xyz);

				// Specular
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow( saturate ( dot(viewDir,reflectDir)) ,_Gloss);

				fixed3 color = ambient + diffuse + specular;
				return fixed4(color, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Diffuse"
}