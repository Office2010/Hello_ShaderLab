// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Exercises/Texture/02_NormalMapTangentSpace"
{
	Properties
	{
		_Color ( "Color Tint", Color) = (1,1,1,1)
		_MainTex ( "Main Tex" , 2D) = "white" {}
		//"bump" 是内置纹理，当没有提供任何纹理时，“bump”对应模型自带的法线信息
		_BumpMap ("Normal Map" , 2D) = "bump" {}
		// _BumpScale 是用于控制 凹凸的程度
		_BumpScale ("Bump Scale" ,Float ) = 1.0
		_Specular ("mySpecular" , Color) = (1,1,1,1)
		_Gloss ("myGloss" , Range(8.0,255)) = 20
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

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			float4 _Specular;
			float _Gloss;

			struct a2v 
			{
				float4 vertex : POSITION ;
				float3 normal : NORMAL ;
				// 跟normal 不同，tangent 是 float4 类型 因为我们需要用其.w 来决定副切线的方向
				float4 tangent : TANGENT ;
				float4 texcoord : TEXCOORD0 ;
			};

			struct v2f
			{
				float4 pos : SV_POSITION ;
				float4 uv : TEXCOORD0 ;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			v2f vert ( a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos( v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				//Compute the bi-normal;
				//float3 binormal = cross (normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
				//Compute a matrix  object space to tangent space.
				//float3x3 rotation = float3x3 (v.tangent.xyz , binormal , v.normal);

				// TANGENT_SPACE_ROTATION 在UnityCG。cginc中定义的 
				TANGENT_SPACE_ROTATION;

				o.lightDir = mul(rotation , ObjSpaceLightDir(v.vertex));
				o.viewDir = mul(rotation , ObjSpaceViewDir(v.vertex));

				return o ;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 tangentLightDir = normalize (i.lightDir);
				float3 tangentViewDir = normalize (i.viewDir);

				float4 packedNormal = tex2D(_BumpMap , i.uv.zw);

				fixed3 tangentNormal;
				tangentNormal.xy = (2 * packedNormal.xy - 1) * _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate( dot(tangentNormal.xy,tangentNormal.xy) ) );

				fixed3 albedo = tex2D(_MainTex , i.uv.xy) * _Color.rgb;

				//ambient
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//diffuse
				fixed3 diffuse = _LightColor0.rgb * albedo * max (0, dot(tangentNormal, tangentLightDir));

				//HalfDir
				fixed3 halfDir = normalize ( tangentNormal + tangentLightDir);
				//Specular
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow( max(0 , dot(tangentNormal,tangentLightDir)) , _Gloss);

				return fixed4(ambient + diffuse + specular,1.0);

				return fixed4(1,1,1,1);
			}

			ENDCG
		}
	}

	Fallback "Diffuse"
}