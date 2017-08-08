Shader "MyShader/Specular/PixelLevel" {
	Properties{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
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

				fixed3 _Diffuse;
				fixed3 _Specular;
				float _Gloss;

				struct a2v {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float3 worldPos : TEXCOORD0;
					fixed3 worldNormal : TEXCOORD1;
					float4 vertex : TEXCOORD2;
				};

				v2f vert(a2v i) {
					v2f o;
					o.pos = UnityObjectToClipPos(i.vertex);
					o.worldPos = UnityObjectToWorldDir(i.vertex.xyz);
					o.worldNormal = UnityObjectToWorldNormal(i.normal);
					o.vertex = i.vertex;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target {
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (0.5 + 0.5*dot(i.worldNormal, worldLight));
					fixed3 view = normalize(WorldSpaceViewDir(i.vertex));
					fixed3 reflectDir = normalize(reflect(-worldLight, i.worldNormal));
					fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(0.5 + 0.5*dot(reflectDir, view), _Gloss);
					return fixed4(ambient + diffuse + specular, 1.0);
				}

				ENDCG
			}
	}
		FallBack "Specular"
}
