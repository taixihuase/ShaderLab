Shader "Custom/Texture/RampTexture" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_RampTex ("Ramp Tex", 2D) = "white" {}
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0,256)) = 20
	}
		SubShader{
				Pass {
					Tags { "LightMode" = "ForwardBase" }

					CGPROGRAM

					fixed4 _Color;
					sampler2D _RampTex;
					fixed4 _Specular;
					float _Gloss;

					#include "UnityCG.cginc"
					#include "Lighting.cginc"
					#pragma vertex vert
					#pragma fragment frag
					
					struct a2v {
						float4 vertex : POSITION;
						float3 normal : NORMAL;
						float4 texcoord : TEXCOORD0;
					};

					struct v2f {
						float4 pos : SV_POSITION;
						float3 worldPos : TEXCOORD0;
						fixed3 worldNormal : TEXCOORD1;
					};

					v2f vert(a2v i) {
						v2f o;
						o.pos = UnityObjectToClipPos(i.vertex);
						o.worldPos = UnityObjectToWorldDir(i.vertex.xyz);
						o.worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
						return o;
					}

					fixed4 frag(v2f i) : SV_Target{
						fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
						fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

						fixed halfLambert = 0.5 + 0.5 * dot(i.worldNormal, worldLightDir);
						fixed3 albedo = _Color.rgb * tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb;
						fixed3 diffuse = _LightColor0.rgb * albedo;

						fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
						fixed3 halfDir = normalize(worldLightDir + worldViewDir);
						fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(0.5 + 0.5*dot(halfDir, i.worldNormal), _Gloss);
						
						return fixed4(ambient + diffuse + specular, 1.0);
					}

					ENDCG
			}
	}
	FallBack "Specular"
}