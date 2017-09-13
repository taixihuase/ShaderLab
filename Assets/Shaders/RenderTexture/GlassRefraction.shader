Shader "Custom/Render Texture/GlassRefraction" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_Cubemap ("Cubemap", Cube) = "_Skybox" {}
		_Distortion ("Distortion", Range(0, 100)) = 10
		_RefractAmount ("Refraction Amount", Range(0,1.0)) = 1.0
	}
		SubShader{
			Tags{ "Queue" = "Transparent" "RenderType" = "Opaque" }
			GrabPass{ "_RefractTex" }

			Pass {
				CGPROGRAM

				#include "UnityCG.cginc"
				#pragma vertex vert
				#pragma fragment frag
				
				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _BumpMap;
				float4 _BumpMap_ST;
				samplerCUBE _Cubemap;
				float _Distortion;
				fixed _RefractAmount;
				sampler2D _RefractTex;
				float4 _RefractTex_TexelSize;

				struct v2f {
					float4 pos : SV_POSITION;
					float3 worldPos : TEXCOORD0;
					float4 scrPos : TEXCOORD1;
					float4 uv : TEXCOORD2;
					float3 T2W0 : TEXCOORD3;
					float3 T2W1 : TEXCOORD4;
					float3 T2W2 : TEXCOORD5;
				};

				v2f vert(appdata_full v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldPos = UnityObjectToWorldDir(v.vertex.xyz);
					o.scrPos = ComputeGrabScreenPos(o.pos);
					o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

					fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
					fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
					fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
					o.T2W0 = float3(worldTangent.x, worldBinormal.x, worldNormal.x);
					o.T2W1 = float3(worldTangent.y, worldBinormal.y, worldNormal.y);
					o.T2W2 = float3(worldTangent.z, worldBinormal.z, worldNormal.z);

					return o;
				}

				fixed4 frag(v2f i) : SV_Target{
					fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
					fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
					
					float2 offset = bump.xy * _Distortion * _RefractTex_TexelSize.xy;
					i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
					fixed3 refractColor = tex2D(_RefractTex, i.scrPos.xy / i.scrPos.w).rgb;
					
					bump = normalize(half3(dot(i.T2W0, bump), dot(i.T2W1, bump), dot(i.T2W2, bump)));
					fixed3 reflectDir = reflect(-worldViewDir, bump);
					fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
					fixed3 reflectColor = texCUBE(_Cubemap, reflectDir).rgb * albedo;

					fixed3 color = reflectColor * (1 - _RefractAmount) + refractColor * _RefractAmount;
					return fixed4(color, 1);
				}

				ENDCG
			}
		}
		FallBack "Diffuse"
}
