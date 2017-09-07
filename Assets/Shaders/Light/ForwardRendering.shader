Shader "Custom/Light/ForwardRendering" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0,256)) = 20
	}
		SubShader{
				Pass {
					Tags { "LightMode" = "ForwardBase" }

					CGPROGRAM

					#pragma multi_compile_fwdbase
					#pragma vertex vert
					#pragma fragment frag
					#include "UnityCG.cginc"
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
					#include "UnityCG.cginc"
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
					};

					struct light {
						float4 _ShadowCoord : TEXCOORD0;
						#ifdef POINT
							float3 _LightCoord : TEXCOORD1;
						#else
							float4 _LightCoord : TEXCOORD1;
						#endif
					};

					a2v v;

					v2f vert(a2v i) {
						v.vertex = i.vertex;

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

						light l;
						TRANSFER_VERTEX_TO_FRAGMENT(l);
						fixed atten = LIGHT_ATTENUATION(l);

						//#ifdef USING_DIRECTIONAL_LGITH
						//	fixed atten = 1.0;
						//#else
						//	//点光源
						//	#if defined(POINT)
						//		float3 lightCoord = mul(unity_WorldToLight,float4(i.worldPos,1)).xyz;
						//		//使用点到光源的距离值的平方来取样，可以避开开方操作
						//		//使用宏UNITY_ATTEN_CHANNEL来得到衰减纹理中衰减值所在的分量，以得到最终的衰减值。
						//		fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
						//		//聚光灯
						//	#elif defined(SPOT)
						//		float4 lightCoord = mul(unity_WorldToLight,float4(i.worldPos,1));
						//		//角度衰减，距离衰减
						//		fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0,lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
						//	#else
						//		fixed atten = 1.0;
						//	#endif
						//#endif
						return fixed4(ambient + (diffuse + specular)*atten, 1.0);
					}

					ENDCG
			}
	}
	FallBack "Specular"
}
