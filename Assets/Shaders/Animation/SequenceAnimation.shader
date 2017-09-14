Shader "Custom/Animation/Sequence Animation" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_AmountX ("Horizontal Amount", Float) = 4
		_AmountY ("Vertical Amount", Float) = 4
		_Speed ("Speed", Range(1.0, 100)) = 30
	}
	SubShader {
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		
		Pass {
			Tags {"LightMode" = "ForwardBase"}

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _AmountX;
			float _AmountY;
			float _Speed;

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert (appdata_base v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				float time = floor(_Time.y * _Speed);
				float row = floor(time / _AmountX);
				float col = time - row * _AmountY;
				float x = 1.0 / _AmountX;
				float y = 1.0 / _AmountY;
				half2 uv = float2(i.uv.x * x, i.uv.y * y);
				uv.x += col * x;
				uv.y -= row * y;

				fixed4 color = tex2D(_MainTex, uv);
				color.rgb *= _Color;
				return color;
			}

			ENDCG
		}
	}
	FallBack "Transparent/VertexLit"
}
