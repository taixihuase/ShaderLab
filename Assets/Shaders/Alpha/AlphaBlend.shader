Shader "Custom/Alpha/AlphaBlend" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_AlphaScale("Alpha Scale", Range(0, 1)) = 1
	}
		SubShader{
			Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
			Pass {
				Tags { "LightMode" = "ForwardBase" }

				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha

				CGPROGRAM

				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#pragma vertex vert
				#pragma fragment frag

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed _AlphaScale;

				struct a2v {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 texcoord : TEXCOORD0;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float3 worldPos : TEXCOORD0;
					fixed3 worldNormal : TEXCOORD1;
					float2 uv : TEXCOORD2;
				};

				v2f vert(a2v i) {
					v2f o;
					o.pos = UnityObjectToClipPos(i.vertex);
					o.worldPos = UnityObjectToWorldDir(i.vertex.xyz);
					o.worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
					o.uv = TRANSFORM_TEX(i.texcoord, _MainTex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target{
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					fixed4 texColor = tex2D(_MainTex, i.uv);
					fixed3 albedo = _Color.rgb * texColor.rgb;
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
					fixed3 diffuse = _LightColor0.rgb * albedo * (0.5 + 0.5*dot(i.worldNormal, worldLightDir));
					return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
				}

				ENDCG
		}
	}
	FallBack "Transparent/VertexLit"
}
