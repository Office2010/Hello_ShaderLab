// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader"Exercises/Alpha/04_DoubelSideAlphaBlending"
{
	Properties
	{
		_Color ("控制整体色调 ColorTint" , Color) = (1,1,1,1)
		_MainTex ("Main Tex" , 2D) = "white"{}
		_AlphaScale ("控制整体的透明度" , Range( 0,1)) = 1
	}

	SubShader
	{
		//渲染队列 设置为：Transparent 这个队列渲染顺序在 AlphaTest 后 ， 然后再按照 从后到前的渲染顺序 渲染
		// IgnoreProjector 设置成 True 忽略投影器 Projector 影响
		// 将此 Shader 归于 Transparent 组中，
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

		// 开启深度写入，但不输出颜色 （相当于 只把模型的深度信息写入深度缓冲中，而颜色不管）提出模型中自身遮挡的部分。
		// 缺点是 开了一个Pass 造成性能开销。
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

			// 关闭深度写入 。防止半透明后的物体看不到：前面未半透明，经过深度检测后，前面的颜色会代替后面的颜色，
			// 如果关闭写入，深度缓冲区(Z-Buffer) 只是一个只读属性。半透明的物体只能跟他后面的颜色进行混合。
			ZWrite Off
			// 开启混合 ， 并设置混合因子。
			//源颜色(该片元产生的颜色) X SrcAlpha, 颜色缓冲区存的颜色会 X OneMinusSrcAlpha,然后把两者相加存到颜色缓冲中
			Blend SrcAlpha OneMinusSrcAlpha

			Cull Front

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;

			struct a2v 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o ;
				o.pos = UnityObjectToClipPos( v.vertex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				o.worldPos = mul(unity_ObjectToWorld , v.vertex).xyz;

				o.uv = TRANSFORM_TEX(v.texcoord , _MainTex);
				return o;
			}

			fixed4 frag(v2f i ) : SV_Target
			{
				fixed3 worldNormal = normalize ( i.worldNormal);
				fixed3 worldLightDir = normalize( UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex , i.uv);
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * saturate( dot(worldNormal , worldLightDir));

				return fixed4(ambient + diffuse , texColor.a * _AlphaScale);
			}
			ENDCG
		}
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

			// 关闭深度写入 。防止半透明后的物体看不到：前面未半透明，经过深度检测后，前面的颜色会代替后面的颜色，
			// 如果关闭写入，深度缓冲区(Z-Buffer) 只是一个只读属性。半透明的物体只能跟他后面的颜色进行混合。
			ZWrite Off
			// 开启混合 ， 并设置混合因子。
			//源颜色(该片元产生的颜色) X SrcAlpha, 颜色缓冲区存的颜色会 X OneMinusSrcAlpha,然后把两者相加存到颜色缓冲中
			Blend SrcAlpha OneMinusSrcAlpha

			Cull Back

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;

			struct a2v 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o ;
				o.pos = UnityObjectToClipPos( v.vertex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				o.worldPos = mul(unity_ObjectToWorld , v.vertex).xyz;

				o.uv = TRANSFORM_TEX(v.texcoord , _MainTex);
				return o;
			}

			fixed4 frag(v2f i ) : SV_Target
			{
				fixed3 worldNormal = normalize ( i.worldNormal);
				fixed3 worldLightDir = normalize( UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex , i.uv);
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * saturate( dot(worldNormal , worldLightDir));

				return fixed4(ambient + diffuse , texColor.a * _AlphaScale);
			}
			ENDCG
		}
	}

	Fallback "Diffuse"
}