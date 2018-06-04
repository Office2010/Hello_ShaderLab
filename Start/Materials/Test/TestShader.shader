// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Test/TestShader"
{
	Properties
	{
		_Diffuse ("myDiffuse" , Color) = (1,1,1,1)
		_Specular ("mySpecular" , Color) = (1,1,1,1)
		_Gloss ("myGloss" , Range(8.0, 255)) = 20
	}

	SubShader{
		// Base Pass
		Pass
		{
			Tags { "LightMode" = "ForwardBase"}

		CGPROGRAM

		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile_fwdbase
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
			fixed3 worldPos : TEXCOORD1;
		};

		v2f vert( a2v v)
		{
			v2f o;

			o.pos = UnityObjectToClipPos(v.vertex);
			//o.worldNormal = mul(_Object2World , v.normal).xyz;
			o.worldNormal = UnityObjectToWorldNormal(v.normal);
			o.worldPos = mul(unity_ObjectToWorld , v.vertex).xyz;

			return o;
		}

		fixed4 frag( v2f i) : SV_Target
		{
			fixed3 worldNormal = normalize (i.worldNormal);
			fixed3 worldLightDir = normalize (UnityWorldSpaceLightDir(i.worldPos));
			fixed3 worldView = normalize ( UnityWorldSpaceViewDir(i.worldPos) ).xyz;

			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

			//fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate( dot(worldNormal,worldLightDir) );
			//(0.6 * dot ( worldNormal,worldLightPos) + 0.4);
			fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb *(0.6 * dot(worldNormal,worldLightDir) + 0.4);
			
			fixed3 h = normalize (worldView + worldLightDir );
			fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow( saturate( dot(h, worldView))  , _Gloss );

			// 衰减值
			fixed atten = 1.0;
			return fixed4(ambient + (diffuse + specular)*atten , 1.0f);
		}

		ENDCG
		}
	}

	Fallback "Diffuse"
}