// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Exercises/ShadowRender/01_ShadowRender"
{
	Properties
	{
		_Diffuse ("myDiffuse" , Color) = (1,1,1,1)
		_Specular ("mySpecular" , Color) = (1,1,1,1)
		_Gloss ("myGloss" , Range(8.0, 255)) = 20
	}

	SubShader{
		Tags {"RenderType"="Opaque"}

		// Base Pass
		Pass
		{
			Tags { "LightMode" = "ForwardBase"}

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
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
				// 这个宏的作用  声明一个队阴影纹理采样的坐标
				// 参数是 下个可用差值寄存器的 索引 ，前面的worldNormal 与 worldPos 已经使用了索引 0 和 1 所以这里索引是 2
				SHADOW_COORDS(2)
			};
			
			v2f vert( a2v v)
			{
				v2f o;
			
				o.pos = UnityObjectToClipPos(v.vertex);
				//o.worldNormal = mul(_Object2World , v.normal).xyz;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld , v.vertex).xyz;

				//  计算 阴影纹理坐标
				TRANSFER_SHADOW(o);
			
				return o;
			}
			
			fixed4 frag( v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize (i.worldNormal);
				fixed3 worldLightDir = normalize (UnityWorldSpaceLightDir(i.worldPos));
				//fixed3 worldView = normalize ( UnityWorldSpaceViewDir(i.worldPos) ).xyz;
				fixed3 worldView = normalize (_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate( dot(worldNormal,worldLightDir) );
			
				fixed3 h = normalize (worldView + worldLightDir );
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow( saturate( dot(h, worldView))  , _Gloss );

				fixed shadow = SHADOW_ATTENUATION(i);

				fixed atten = 1.0;
				return fixed4(ambient + (diffuse + specular )*atten*shadow, 1.0f);
			}

			ENDCG
		}


		// Additional Pass  ___________________________________________________________________________
		Pass
		{
			Tags {"LightMode"="ForwardAdd"}

			Blend One One

			CGPROGRAM

			#pragma multi_compile_fwdadd
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
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

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);//normalize (UnityWorldSpaceLightDir(i.worldPos));
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
				#endif

				fixed3 worldView = normalize ( UnityWorldSpaceViewDir(i.worldPos) ).xyz;
			
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate( dot(worldNormal,worldLightDir) );
			
				fixed3 h = normalize (worldView + worldLightDir );
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow( saturate( dot(h, worldView))  , _Gloss );

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					float3 lightCoord = mul (unity_WorldToLight , float4(i.worldPos,1.0)).xyz;
					fixed atten = tex2D(_LightTexture0 , dot(lightCoord , lightCoord).rr).UNITY_ATTEN_CHANNEL;
				#endif

				return fixed4( (diffuse + specular )*atten, 1.0f);
			}
			ENDCG
		}
	}

	Fallback "Diffuse"
}