// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Exercises/Alpha/01_AlphaTest"
{
	Properties
	{
		_Color ( "Color Tint" ,Color) = (1,1,1,1)
		_MainTex( "Main Tex" , 2D) = "white" {}
		_CutOff ("控制透明度测试时 使用的阈值" , Range(0 , 1.0)) = 0.5
	}

	SubShader 
	{
		// 1.透明度测试 使用的渲染队列为 AlphaTest 。用 Queue 标签设置
		// 2.RenderType 标签可以让此 shader 归入到提前定义的组， 这里是 TransparentCutout
		//				指明了此shader使用了透明度测试。 RenderType 标签通常用于 着色器 替换功能。
		// 3.IgnoreProjector 标签设置成 True 表示 此Shader不会受到投影器（Projectors）的影响。
		Tags{"Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}
		// 使用了透明度测试的 Shader 都应该在 SubShader 中设置这三个标签。
		// ——————————————————————————————————————————————————————————————————————————

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _CutOff;

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

			v2f vert ( a2v v) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(  v.vertex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul (unity_ObjectToWorld , v.vertex) .xyz;
				o.uv = TRANSFORM_TEX(v.texcoord , _MainTex);

				return o;
			}

			fixed4 frag ( v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize (i.worldNormal);
				fixed3 worldLightDir = normalize( UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex ,i.uv);
				//透明度检测
				clip(texColor.a - _CutOff);
				//  ==> :
				//		if((texColor.a - _Cutoff) < 0.0)
				//			discard;

				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate( dot(worldNormal,worldLightDir));

				return fixed4(ambient + diffuse ,1.0);
			}

			ENDCG
		}
	}

	Fallback "Diffuse"
}