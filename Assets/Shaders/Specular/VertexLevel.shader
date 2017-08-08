Shader "MyShader/Specular/VertexLevel" {
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

				float3 _Diffuse;
				float3 _Specular;
				float _Gloss;

				struct a2v {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};

				struct v2f {
					fixed4 pos : SV_POSITION;
					fixed3 color : COLOR;
				};

				v2f vert(a2v i) {
					v2f o;
					o.pos = normalize(UnityObjectToClipPos(i.vertex));
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
					fixed3 worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
					fixed3 diffuse = _LightColor0.xyz * _Diffuse.rgb * (0.5 + 0.5*dot(worldNormal, worldLight));
					fixed3 reflectDir = normalize(reflect(-worldLight, worldNormal));
					fixed3 viewDir = normalize(WorldSpaceViewDir(i.vertex));
					fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(0.5 + 0.5*dot(reflectDir, viewDir), _Gloss);
					o.color = ambient + diffuse + specular;
					return o;
				}

				fixed4 frag(v2f i) :SV_Target {
					return fixed4(i.color, 1.0);
				
				}

				ENDCG
		}
	}
		FallBack "Specular"
}
