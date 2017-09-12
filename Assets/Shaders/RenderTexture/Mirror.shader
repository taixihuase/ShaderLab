Shader "Custom/Render Texture/Mirror" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0,256)) = 20
		_MainTex("Main Tex", 2D) = "white" {}
	}
		SubShader{
			Pass {
				Tags { "LightMode" = "ForwardBase" }

				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase

				#include "UnityCG.cginc"
				#include "Lighting.cginc"

				fixed4 _Color;
				sampler _MainTex;
				fixed4 _Specular;
				float _Gloss;

				struct v2f {
					float4 pos : SV_POSITION;
					fixed3 worldNormal : TEXCOORD0;
					float3 worldPos : TEXCOORD1;
					float2 uv : TEXCOORD2;
				};

				v2f vert(appdata_full v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
					o.worldPos = UnityObjectToWorldDir(v.vertex.xyz);
					o.uv = TRANSFORM_UV(2);
					o.uv.x = 1 - o.uv.x;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target {
					fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					fixed3 diffuse = _LightColor0.rgb * albedo * (0.5 + 0.5*dot(i.worldNormal, worldLightDir));
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