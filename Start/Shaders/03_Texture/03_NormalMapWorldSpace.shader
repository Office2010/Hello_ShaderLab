// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Exercises/Texture/03_NormalMapWorldSpace"
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
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;	
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
			};

			v2f vert (a2v v) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos ( v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 worldPos = mul(unity_ObjectToWorld , v.vertex).xyz;

				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBiNormal = cross (worldNormal,worldTangent) * v.tangent.w;

				o.TtoW0 = float4( worldTangent.x , worldBiNormal.x , worldNormal.x , worldPos.x);
				o.TtoW1 = float4( worldTangent.y , worldBiNormal.y , worldNormal.y , worldPos.y);
				o.TtoW2 = float4( worldTangent.z , worldBiNormal.z , worldNormal.z , worldPos.z);
				return o;
			}

			fixed4 frag ( v2f i) : SV_Target
			{
				//get position in world space
				float3 worldPos = float3 ( i.TtoW0.w , i.TtoW1.w , i.TtoW2.w);
				// compute lightDir
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				// compute viewDir
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir(worldPos));

				fixed4 packedNormal = tex2D ( _BumpMap , i.uv.zw);
				fixed3 tangentNormal;
				//tangentNormal.xy = ( 2 * packedNormal.xy - 1) * _BumpScale;
				tangentNormal = UnpackNormal (packedNormal) * _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate( dot(tangentNormal.xy , tangentNormal.xy)));

				fixed3 worldNormal = normalize( float3( dot(i.TtoW0.xyz , tangentNormal) , dot(i.TtoW1.xyz ,tangentNormal) , dot(i.TtoW2.xyz , tangentNormal)));

				fixed3 albedo = tex2D(_MainTex , i.uv) * _Color.rgb;

				//ambient
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				//diffuse
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal ,worldLightDir));
				//specular
				fixed3 halfDir = normalize(worldLightDir + worldViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow( saturate(dot(worldNormal , halfDir)) ,_Gloss);

				return fixed4(ambient + diffuse + specular , 1.0);


			}
			ENDCG
		}
	}
}