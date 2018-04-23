// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Exercises/Diffuse/01_SimpleShader"
{
	Properties
	{
		_Color ("myColor" , Color) = (1.0,1.0,1.0,1.0)
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			//访问属性 需要再CG代码中定义 一个与属性名称和类型都匹配的变量
			fixed4 _Color;

			struct model2vert
			{
				// POSITION 语义  告诉Unity 用模型空间的顶点坐标 填充 modelVert 变量
				float4 vertex : POSITION ;
				// NORMAL   语义  告诉Unity 用模型空间的法线方向 填充 modelNor 变量
				float3 normal : NORMAL ;
				// TEXCOORD0 语义  告诉Unity 用模型的第一套纹理坐标 填充 texcoord 变量
				float4 texcoord : TEXCOORD0 ;
			};

			struct vert2frag
			{
				// SV_POSITION 语义 告诉Unity pos里存放的是顶点在裁剪空间的位置
				float4 pos : SV_POSITION ;
				// COLOR0      语义  可用于存储颜色信息
				fixed3 color : COLOR0;
			};

			vert2frag vert (model2vert v) 
			{
				vert2frag o ;
				o.pos = UnityObjectToClipPos (v.vertex);
				o.color = v.normal * 0.5f + fixed3(0.5 , 0.5f , 0.5f);
				return o;
			}

			float4 frag (vert2frag i) :SV_TARGET
			{
				fixed3 c = i.color;
				c *= _Color.rgb;
				return fixed4 (c ,1.0);
			}

			ENDCG
		}
	}
}