
struct appdata{
	float4 vertex : POSITION;
	float2 texcoord : TEXCOORD0;
	float3 normal : NORMAL;
};
struct v2f{
	float4 pos: SV_POSITION;
	half4 uv: TEXCOORD0;
	float3 worldNormal: TEXCOORD1;
	float3 worldPos: TEXCOORD2;
	float3 normal: TEXCOORD3;
    UNITY_SHADOW_COORDS(7)
};
fixed Ls;
fixed4 _Color;
fixed4 _Specular;
half _Shininess;

sampler2D _MainTex;
half4 _MainTex_ST;
sampler2D _FurTex;
half4 _FurTex_ST;
half4 _UVoffset;
fixed _LitFil;
float _dming;
fixed _FurLength;
fixed _FurDensity;
fixed _FurThinness;
fixed _FurShading;

float4 _ForceGlobal;
float4 _ForceLocal;

fixed4 _RimColor;
half _RimPower;


v2f vert_surface(appdata v){
	v2f o;
	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
	o.worldNormal = UnityObjectToWorldNormal(v.normal);
	o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	TRANSFER_SHADOW(o);

	return o;
}

v2f vert_base(appdata_base v){
	v2f o;
	float3 P = v.vertex.xyz+v.normal*_FurLength*FUROFFSET;
	P += clamp(mul(unity_WorldToObject, _ForceGlobal).xyz+_ForceLocal.xyz, -1, 1)*pow(FUROFFSET, 2.3)*_FurLength;
	// P += clamp(mul(unity_WorldToObject, _ForceGlobal).xyz+_ForceLocal.xyz, -1, 1)*pow(FUROFFSET, 3)*_FurLength;
	o.pos = UnityObjectToClipPos(float4(P,1.0));
	float2 uvOS = _UVoffset.xy*FUROFFSET*0.1;
	float2 uv1 = TRANSFORM_TEX(v.texcoord.xy,_MainTex)+uvOS*(float2(1,1)/_FurTex_ST.xy);
	float2 uv2 = TRANSFORM_TEX(v.texcoord.xy,_MainTex)*_FurTex_ST.xy+uvOS;
	o.uv = float4(uv1,uv2);
	o.worldNormal = UnityObjectToWorldNormal(v.normal);
	o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

	o.normal = normalize(mul(UNITY_MATRIX_MV, float4(v.normal,0)).xyz);
    UNITY_TRANSFER_SHADOW(o, v.uv.xy);
// half3 worldNormal = UnityObjectToWorldNormal(v.normal);
// 	half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
// 	// factor in the light color
// 	o.difColor = nl * _LightColor0;
// 	o.difColor.rgb += ShadeSH9(half4(worldNormal,1));
	return o;
}

fixed4 frag_surface(v2f i): SV_Target{
	fixed3 worldNormal = normalize(i.worldNormal);
	fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
	fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz-i.worldPos.xyz);
	fixed3 worldHalf = normalize(worldView+worldLight);

	fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb;//*_Color
	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb*albedo;
	UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
	half3 NoL = dot(worldLight,worldNormal);
	half DirLight = pow(saturate(NoL+_LitFil+FUROFFSET),_RimPower);
	fixed3 diffuse = _LightColor0.rgb*albedo*saturate(dot(worldNormal, worldLight));
	// fixed3 spe = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(worldNormal, worldHalf)), _Shininess);
	fixed3 color = ambient+atten*diffuse*DirLight*3;

	return fixed4(color*albedo*_FurShading*_Color, 1.0);
}

fixed4 frag_base(v2f i): SV_Target{
	fixed3 worldNormal = normalize(i.worldNormal);
	fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
	fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz-i.worldPos.xyz);
	fixed3 worldHalf = normalize(worldNormal+worldLight);

	// fixed3 lightWithShadow = _LightColor0.rgb * Shadow;
                // fixed Shadow = SHADOW_ATTENUATION(i);
    UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
	float3 normal = normalize(mul(UNITY_MATRIX_MV, float4(i.worldNormal,0)).xyz);
	half3 SH = saturate(normal.z*0.2+0.12);//0.25+0.35

	fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb;
	fixed3 tex = tex2D(_MainTex, i.uv.xy).rgb;
	//albedo -= (pow(1-FUROFFSET, 4))*_FurShading;

	half3 NoL = dot(worldLight,worldNormal);
	half DirLight = saturate(NoL+_LitFil+FUROFFSET);
	// half rim = 1.0 - dot(worldView, worldNormal);
	// albedo += fixed4(_RimColor.rgb*pow(rim, _RimPower), 1.0);
	// fixed3 shadow = saturate(NoL);
	// fixed3 shadow = saturate(dot(worldNormal, worldLight));
	fixed3 halfshadow = saturate(dot(worldNormal,worldHalf));
	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb*albedo;
    fixed3 diffuse = _LightColor0.rgb * albedo.rgb * pow(DirLight, _RimPower) * atten;
	fixed3 spe = _LightColor0.rgb*_Specular.rgb*pow(halfshadow, _Shininess);


	fixed3 color = lerp(diffuse,albedo,FUROFFSET);
	color = diffuse+ambient*0.45+spe;

	fixed3 noise = tex2D(_FurTex, i.uv.zw*_FurThinness).rgb;
	half Nois = noise.r;
	fixed alpha = clamp(Nois*2-(FUROFFSET*FUROFFSET+(FUROFFSET*Nois*5))*_FurDensity,0,1);
	// fixed alpha = clamp(Nois-(FUROFFSET*FUROFFSET)*_FurDensity, 0, 1);
	return fixed4(color*_Color, alpha); //+saturate(SHL)

}