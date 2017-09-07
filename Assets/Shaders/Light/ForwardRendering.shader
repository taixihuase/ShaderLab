Shader "Custom/Light/ForwardRendering" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0,256)) = 20
	}
		SubShader{
			Tags{ "RenderType" = "Opaque" }
				Pass {
					Tags { "LightMode" = "ForwardBase" }

					CGPROGRAM

					#pragma multi_compile_fwdbase
					#pragma vertex vert
					#pragma fragment frag
					#include "Lighting.cginc"

					fixed4 _Color;
					sampler2D _MainTex;
					float4 _MainTex_ST;
					fixed4 _Specular;
					float _Gloss;

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
						fixed3 albedo = _Color.rgb * tex2D(_MainTex, i.uv).rgb;
						fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
						fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
						fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
						fixed3 halfDir = normalize(worldLightDir + worldViewDir);
						fixed3 diffuse = _LightColor0.rgb * albedo * (0.5 + 0.5*dot(i.worldNormal, worldLightDir));
						fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(0.5 + 0.5*dot(i.worldNormal, halfDir), _Gloss);
						return fixed4(ambient + diffuse + specular, 1.0);
					}

					ENDCG
			}

				Pass {
					Tags { "LightMode" = "ForwardAdd" }

					Blend One One
				
					CGPROGRAM

					#pragma multi_compile_fwdadd
					#pragma vertex vert
					#pragma fragment frag
					#include "Lighting.cginc"
					#include "AutoLight.cginc"

					fixed4 _Color;
					sampler2D _MainTex;
					float4 _MainTex_ST;
					fixed4 _Specular;
					float _Gloss;

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
						LIGHTING_COORDS(3, 4)
					};

					v2f vert(a2v v) {
						v2f o;
						o.pos = UnityObjectToClipPos(v.vertex);
						o.worldPos = UnityObjectToWorldDir(v.vertex.xyz);
						o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
						o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
						TRANSFER_VERTEX_TO_FRAGMENT(o)
						return o;
					}

					fixed4 frag(v2f i) : SV_Target{
						fixed3 albedo = _Color.rgb * tex2D(_MainTex, i.uv).rgb;
						fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
						fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
						fixed3 halfDir = normalize(worldLightDir + worldViewDir);
						fixed3 diffuse = _LightColor0.rgb * albedo * (0.5 + 0.5*dot(i.worldNormal, worldLightDir));
						fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(0.5 + 0.5*dot(i.worldNormal, halfDir), _Gloss);

						UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos)
						return fixed4((diffuse + specular)*atten, 1.0);
					}

					ENDCG
			}
	}
	FallBack "Specular"
}
