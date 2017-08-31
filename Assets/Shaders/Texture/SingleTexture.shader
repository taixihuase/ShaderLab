Shader "Custom/Texture/SingleTexture" {
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

					#pragma vertex vert
					#pragma fragment frag

					#include "UnityCG.cginc"
					#include "Lighting.cginc"

					fixed4 _Color;
					sampler _MainTex;
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
						fixed3 worldNormal : TEXCOORD0;
						float3 worldPos : TEXCOORD1;
						float2 uv : TEXCOORD2;
					};

					v2f vert(a2v i) {
						v2f o;
						o.pos = UnityObjectToClipPos(i.vertex);
						o.worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
						o.worldPos = UnityObjectToWorldDir(i.vertex.xyz);
						o.uv = TRANSFORM_TEX(i.texcoord, _MainTex);
						return o;
					}

					fixed4 frag(v2f i) : SV_Target {
						fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
						fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
						fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
						fixed3 diffuse = _LightColor0.rgb * albedo * (0.5 + 0.5*dot(i.worldNormal, worldLightDir));
						fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
						fixed3 halfDir = normalize(worldLightDir + viewDir);
						fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(0.5 + 0.5*dot(halfDir, i.worldNormal), _Gloss);
						return fixed4(ambient + diffuse + specular, 1.0);
					}

					ENDCG
			}
	}
	FallBack "Specular"
}