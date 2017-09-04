Shader "Custom/Texture/NormalMapInWorldSpace" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Bump", 2D) = "bump" {}
		_BumpScale("BumpScale", Float) = 1.0
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0,256)) = 20
	}
		SubShader{
				Pass {
					Tags { "LightMode" = "ForwardBase" }

					CGPROGRAM

					#include "UnityCG.cginc"
					#include "Lighting.cginc"

					#pragma vertex vert
					#pragma fragment frag

					fixed4 _Color;
					sampler2D _MainTex;
					float4 _MainTex_ST;
					sampler2D _BumpMap;
					float4 _BumpMap_ST;
					float _BumpScale;
					fixed4 _Specular;
					float _Gloss;
					
					struct a2v {
						float4 vertex : POSITION;
						float3 normal : NORMAL;
						float4 tangent : TANGENT;
						float4 texcoord : TEXCOORD0;
					};

					struct v2f {
						float4 pos : SV_POSITION;
						float3 worldPos : TEXCOORD0;
						float4 uv : TEXCOORD1;
						float3 Tangent2World0 : TEXCOORD2;
						float3 Tangent2World1 : TEXCOORD3;
						float3 Tangent2World2 : TEXCOORD4;
					};

					v2f vert(a2v i) {
						v2f o;
						o.pos = UnityObjectToClipPos(i.vertex);
						o.worldPos = UnityObjectToWorldDir(i.vertex.xyz);
						o.uv.xy = TRANSFORM_TEX(i.texcoord, _MainTex);
						o.uv.zw = TRANSFORM_TEX(i.texcoord, _BumpMap);

						fixed3 worldNormal = UnityObjectToWorldNormal(i.normal);
						fixed3 worldTangent = UnityObjectToWorldDir(i.tangent);
						fixed3 worldBinormal = cross(worldNormal, worldTangent) * i.tangent.w;
						o.Tangent2World0 = float3(worldTangent.x, worldBinormal.x, worldNormal.x);
						o.Tangent2World1 = float3(worldTangent.y, worldBinormal.y, worldNormal.y);
						o.Tangent2World2 = float3(worldTangent.z, worldBinormal.z, worldNormal.z);

						return o;
					}

					fixed4 frag(v2f i) : SV_Target{
						fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
						fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
						fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
						fixed3 halfDir = normalize(lightDir + viewDir);

						fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
						bump.xy *= _BumpScale;
						bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
						bump = normalize(half3(dot(i.Tangent2World0, bump), dot(i.Tangent2World1, bump), dot(i.Tangent2World2, bump)));

						fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
						fixed3 diffuse = _LightColor0.rgb * albedo * (0.5 + 0.5*dot(bump, lightDir));
						fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(0.5 + 0.5*dot(halfDir, bump), _Gloss);

						return float4(ambient + diffuse + specular, 1.0);
					}
			
					ENDCG
		}
	}
	FallBack "Specular"
}
