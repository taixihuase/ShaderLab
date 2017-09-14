Shader "Custom/Animation/Scroll" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_ScrollSpeedX ("Scroll Speed X", Float) = 1.0
		_ScrollSpeedY ("Scroll Speed Y", Float) = 1.0
	}
	SubShader {
			Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
			Pass {
				Tags { "LightMode" = "ForwardBase" }

				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha

				CGPROGRAM

				#include "UnityCG.cginc"
				#pragma vertex vert
				#pragma fragment frag

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _ScrollSpeedX;
				float _ScrollSpeedY;

				struct v2f {
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
				};

				v2f vert(appdata_base v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.uv += float2(_ScrollSpeedX, _ScrollSpeedY) * _Time.y;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target {
					fixed4 color = tex2D(_MainTex, i.uv);
					return color;
				}

				ENDCG
			}
	}
	FallBack "Transparent/VertexLit"
}
