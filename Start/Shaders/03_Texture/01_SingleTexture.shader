// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Exercises/Texture/01_SingleTexture"
{
	Properties
	{
		_Color ("Color Tint" , Color ) = (1,1,1,1)
		_MainTex ("Main Tex" , 2D) = "white" {}
		_Specular ( "mySpecular" ,Color ) = (1,1,1,1)
		_Gloss ("myGLoss" , Range(8.0 , 255) ) = 20
	}

	SubShader
	{
		Pass
		{
			Tags{ "LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			//为纹理声明一个float4 类型的变量，命名规则为： 纹理名_ST
			// ST 为（scale）和（Transform）的缩写，我们可以得到该纹理的缩放与偏移值。
			float4 _MainTex_ST;		//_MainTex_ST.xy 为缩放， .zw 为偏移值
			fixed4 _Specular;
			fixed4 _Gloss;

			struct a2v
			{	
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				//将Unity 模型的第一组纹理坐标存储到该变量中。
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert ( a2v v) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos( v.vertex);

				o.worldNormal = UnityObjectToWorldNormal ( v.normal);

				o.worldPos = mul(unity_ObjectToWorld , v.vertex);

				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				// Of crouse  #include "UnityCG.cginc"  o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);  can instand of

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				
				// worldNormal
				fixed3 worldNormal = normalize ( i.worldNormal);
				// worldLightDir
				fixed3 worldLightDir = normalize ( UnityWorldSpaceLightDir (i.worldPos));
				// use the texture to sample to diffuse color
				// tex2D : 为CG内置函数 ， 对纹理进行采样，参数列表： （要采样的纹理 ， float2类型的纹理坐标）
				fixed3 albedo = tex2D (_MainTex , i.uv).rgb * _Color.rgb;

				//ambient
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//Diffuse
				fixed3 diffuse = _LightColor0.rgb * albedo * max (0, dot (worldNormal,worldLightDir));

				//Blinn-Phong
				fixed3 viewDir = normalize ( UnityWorldSpaceViewDir (i.worldPos));
				fixed3 halfDir = normalize ( worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow ( max (0, dot (worldNormal,halfDir)) , _Gloss );

				return fixed4( ambient + diffuse + specular , 1.0);
			}
			ENDCG
		}
	}

	Fallback "Diffuse"
}