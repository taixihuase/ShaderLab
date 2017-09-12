Shader "Custom/Cubemap Texture/Reflection" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_ReflectColor ("Reflection Color", Color) = (1,1,1,1)
		_ReflectAmount ("Reflection Amount", Range(0,1)) = 1
		_Cubemap ("Reflection Cubemap", Cube) = "_Skybox" {}
	}
		SubShader{
			Pass {
				Tags { "LightMode" = "ForwardBase" "RenderType" = "Opaque" }

				CGPROGRAM

				#include "Lighting.cginc"
				#include "AutoLight.cginc"
				#pragma multi_compile_fwdbase
				#pragma vertex vert
				#pragma fragment frag

				fixed4 _Color;
				fixed4 _ReflectColor;
				fixed _ReflectAmount;
				samplerCUBE _Cubemap;

				struct v2f {
					float4 pos : SV_POSITION;
					float3 worldPos : TEXCOORD0;
					fixed3 worldNormal : TEXCOORD1;
					LIGHTING_COORDS(2, 3)
				};

				v2f vert(appdata_full v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
					o.worldPos = UnityObjectToWorldDir(v.vertex.xyz);
					TRANSFER_VERTEX_TO_FRAGMENT(o)
					return o;
				}

				fixed4 frag(v2f i) : SV_Target{
					fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					fixed3 worldReflectionDir = reflect(-worldViewDir, i.worldNormal);

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
					fixed3 diffuse = _LightColor0.rgb * _Color.rgb * (0.5 + 0.5*dot(i.worldNormal, worldLightDir));

					fixed3 reflection = texCUBE(_Cubemap, worldReflectionDir).rgb * _ReflectColor.rgb;
					UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos)

					return fixed4(ambient + lerp(diffuse * atten, reflection, _ReflectAmount), 1.0);
				}

				ENDCG
		}
	}
	FallBack "Reflective/VertexLit"
}