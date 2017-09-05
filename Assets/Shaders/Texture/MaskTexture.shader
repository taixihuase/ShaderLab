Shader "Custom/Texture/MaskTexture" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1.0
		_SpecularMask("Specular Mask", 2D) = "white" {}
		_SpecularScale("Specular Scale", Float) = 1.0
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
					float _BumpScale;
					sampler2D _SpecularMask;
					float _SpecularScale;
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
						float2 uv : TEXCOORD0;
						float3 tangentLightDir : TEXCOORD1;
						float3 tangentViewDir : TEXCOORD2;
					};

					v2f vert(a2v v) {
						v2f o;
						o.pos = UnityObjectToClipPos(v.vertex);
						o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

						TANGENT_SPACE_ROTATION;
						o.tangentLightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)).xyz);
						o.tangentViewDir = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)).xyz);
						
						return o;
					}

					fixed4 frag(v2f i) : SV_Target{
						fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
						tangentNormal.xy *= _BumpScale;
						tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

						fixed3 albedo = _Color.rgb * tex2D(_MainTex, i.uv).rgb;
						fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
						fixed3 diffuse = _LightColor0.rgb * albedo * (0.5 + 0.5*dot(tangentNormal, i.tangentLightDir));
						fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
						fixed3 halfDir = normalize(i.tangentLightDir + i.tangentViewDir);
						fixed3 specular = _LightColor0.rgb * _Specular.rgb * _SpecularScale * pow(0.5 + 0.5*dot(halfDir, tangentNormal), _Gloss);
						
						return fixed4(ambient + diffuse + specular, 1.0);
					}

					ENDCG
				}
		}
		FallBack "Specular"
}
