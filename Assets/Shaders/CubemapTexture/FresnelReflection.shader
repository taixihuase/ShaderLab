Shader "Custom/Cubemap Texture/Fresnel Reflection" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_FresnelScale ("Fresnel Scale", Range(0,1)) = 0.5
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
				fixed _FresnelScale;
				samplerCUBE _Cubemap;

				struct v2f {
					float4 pos : SV_POSITION;
					float3 worldPos : TEXCOORD0;
					fixed3 worldNormal : TEXCOORD1;
					LIGHTING_COORDS(2,3)
				};

				v2f vert(appdata_full v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldPos = UnityObjectToWorldDir(v.vertex.xyz);
					o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
					TRANSFER_VERTEX_TO_FRAGMENT(o)
					return o;
				}

				fixed4 frag(v2f i) : SV_Target{				
					fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					fixed3 worldReflectDir = reflect(-worldViewDir, i.worldNormal);
					fixed3 reflection = texCUBE(_Cubemap, worldReflectDir).rgb;

					UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos)
					fixed fresnel = _FresnelScale + (1 - _FresnelScale)*pow(1 - dot(worldViewDir,i.worldNormal), 5);
					
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
					fixed3 diffuse = _LightColor0.rgb * _Color.rgb * (0.5 + 0.5*dot(i.worldNormal, worldLightDir));

					return fixed4(ambient + lerp(diffuse*atten, reflection, saturate(fresnel)), 1.0);
				}

				ENDCG
		}
	}
	FallBack "Reflective/VertexLit"
}
