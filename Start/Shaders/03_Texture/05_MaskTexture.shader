// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Exercises/Texture/05_MaskTexture"
{
	Properties 
	{
		_Color ("控制主色调" , Color) = (1,1,1,1)
		_MainTex("纹理贴图" , 2D ) = "white" {}
		_BumpMap("发现贴图" , 2D ) = "bump" {}
		_BumpScale ("控制凹凸程度" , Float) = 1.0
		_SpecularMask("高光反射遮罩" ,2D ) = "white"{}
		_SpecularScale("控制遮罩影响度",Float) = 1.0
		_Specular("高光反射颜色", Color ) = (1,1,1,1)
		_Gloss("材质光泽度，光泽度越大亮点越小" , Range(8.0,255) ) = 20.0
	}

	SubShader
	{
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

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
			sampler2D _SpecularMask;
			float4 _SpecularMask_ST;
			float _SpecularScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			v2f vert ( a2v v)
			{
				v2f o ;
				o.pos = UnityObjectToClipPos(  v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation , ObjSpaceLightDir(v.vertex).xyz);
				o.viewDir = mul(rotation , ObjSpaceViewDir(v.vertex).xyz);
				return o;
			}

			fixed4 frag ( v2f i) : SV_Target
			{
				fixed3 tangentLightDir = normalize ( i.lightDir);
				fixed3 tangentViewDir = normalize ( i.viewDir);

				fixed3 tangentNormal = UnpackNormal (tex2D (_BumpMap , i.uv.zw));
				tangentNormal *= _BumpScale;
				tangentNormal.z = sqrt ( 1.0 - saturate( dot (tangentNormal.xy , tangentNormal.xy)));

				fixed3 albedo = tex2D ( _MainTex ,i.uv.xy) .rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * saturate( dot (tangentLightDir ,tangentNormal));

				fixed3 halfDir = normalize ( tangentLightDir + tangentViewDir);
				fixed specularMask = tex2D(_SpecularMask , i.uv).r * _SpecularScale;
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow( saturate(dot(tangentNormal,halfDir)),_Gloss) * specularMask;

				return fixed4(ambient + diffuse + specular , 1.0);
			}
			ENDCG
		}
	}
}