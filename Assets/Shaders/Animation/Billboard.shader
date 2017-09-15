Shader "Custom/Animation/Billboard" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("MainTex", 2D) = "white" {}
		_VerticalBillboarding ("Vertical Restraints", Range(0,1)) = 1
	}
	SubShader {
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }

		Pass {
			Tags {"LightMode" = "ForwardBase" }

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Front

			CGPROGRAM

			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _VerticalBillboarding;

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata_base v) {
				v2f o;

				float3 center = float3(0, 0, 0);
				float3 centerOffset = v.vertex.xyz - center;
				float3 view = ObjSpaceViewDir(float4(center, v.vertex.w));

				float3 normal = view;
				normal.y *= _VerticalBillboarding;
				normal = normalize(normal);

				float3 tempUp = abs(normal.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
				float3 right = normalize(cross(normal, tempUp));
				float3 up = normalize(cross(normal, right));

				float3 newPos = center + centerOffset.x * right + centerOffset.y * up + centerOffset.z * normal;
				o.pos = UnityObjectToClipPos(float4(newPos, v.vertex.w));
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed4 color = tex2D(_MainTex, i.uv);
				color.rgb *= _Color.rgb;
				return color;
			}

			ENDCG
		}
		
		Pass {
			Tags {"LightMode" = "ForwardBase" }

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back

			CGPROGRAM

			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _VerticalBillboarding;

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata_base v) {
				v2f o;

				float3 center = float3(0, 0, 0);
				float3 centerOffset = v.vertex.xyz - center;
				float3 view = ObjSpaceViewDir(float4(center, v.vertex.w));

				float3 normal = view;
				normal.y *= _VerticalBillboarding;
				normal = normalize(normal);

				float3 tempUp = abs(normal.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
				float3 right = normalize(cross(normal, tempUp));
				float3 up = normalize(cross(normal, right));

				float3 newPos = center + centerOffset.x * right + centerOffset.y * up + centerOffset.z * normal;
				o.pos = UnityObjectToClipPos(float4(newPos, v.vertex.w));
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed4 color = tex2D(_MainTex, i.uv);
				color.rgb *= _Color.rgb;
				return color;
			}

			ENDCG
		}
	}
	FallBack "Transparent/VertexLit"
}
