#ifndef FILE_FOREST_COMMON
#define FILE_FOREST_COMMON

//forest-begin: lightmap occlusion
float4 _LightmapOcclusionLuminanceMode;
float4 _LightmapOcclusionScalePowerReflStrengthSpecStrength;

void GetSpecularOcclusionFromLightmapLuminance_float(float3 V, float3 normalWS, float3 bakedGI, out float specularOcclusion)
{
	float3 lookupVector = _LightmapOcclusionLuminanceMode.w == 0 ? normalWS : reflect(-V, normalWS);;
	float lightmapOcclusion = dot(bakedGI, _LightmapOcclusionLuminanceMode.rgb);
	lightmapOcclusion = pow(saturate(lightmapOcclusion * _LightmapOcclusionScalePowerReflStrengthSpecStrength.x), _LightmapOcclusionScalePowerReflStrengthSpecStrength.y);
	specularOcclusion = lerp(1.f, lightmapOcclusion, _LightmapOcclusionScalePowerReflStrengthSpecStrength.z);
}
//forest-end: lightmap occlusion


//forest-begin: sky occlusion
float _OcclusionProbesReflectionOcclusionAmount;

// Occlusion probes
sampler3D _OcclusionProbes;
float4x4 _OcclusionProbesWorldToLocal;
sampler3D _OcclusionProbesDetail;
float4x4 _OcclusionProbesWorldToLocalDetail;
float4 _AmbientProbeSH[7];

// Grass occlusion
sampler2D _GrassOcclusion;
float _GrassOcclusionAmountTerrain;
float _GrassOcclusionAmountGrass;
float _GrassOcclusionHeightFadeBottom;
float _GrassOcclusionHeightFadeTop;
float4x4 _GrassOcclusionWorldToLocal;
sampler2D _GrassOcclusionHeightmap;
float _GrassOcclusionHeightRange;
float _GrassOcclusionCullHeight;

float SampleGrassOcclusion(float2 terrainUV)
{
    return lerp(1.0, tex2D(_GrassOcclusion, terrainUV).a, _GrassOcclusionAmountTerrain);
}

float SampleGrassOcclusion(float3 positionWS)
{
    float3 pos = mul(_GrassOcclusionWorldToLocal, float4(positionWS, 1)).xyz;
    float terrainHeight = tex2D(_GrassOcclusionHeightmap, pos.xz).a;
    float height = pos.y - terrainHeight * _GrassOcclusionHeightRange;

    UNITY_BRANCH
        if (height < _GrassOcclusionCullHeight)
        {
            float xz = lerp(1.0, tex2D(_GrassOcclusion, pos.xz).a, _GrassOcclusionAmountGrass);
            return saturate(xz + smoothstep(_GrassOcclusionHeightFadeBottom, _GrassOcclusionHeightFadeTop, height));

            // alternatively:    
            // float amount = saturate(smoothstep(_GrassOcclusionHeightFade, 0, pos.y) * _GrassOcclusionAmount);
            // return lerp(1.0, tex2D(_GrassOcclusion, pos.xz).a, amount);
        }
        else
            return 1;
}

float SampleOcclusionProbes(float3 positionWS)
{
    // TODO: no full matrix mul needed, just scale and offset the pos (don't really need to support rotation)
    float occlusionProbes = 1;

    float3 pos = mul(_OcclusionProbesWorldToLocalDetail, float4(positionWS, 1)).xyz;

    UNITY_BRANCH
        if (all(pos > 0) && all(pos < 1))
        {
            occlusionProbes = tex3D(_OcclusionProbesDetail, pos).a;
        }
        else
        {
            pos = mul(_OcclusionProbesWorldToLocal, float4(positionWS, 1)).xyz;
            occlusionProbes = tex3D(_OcclusionProbes, pos).a;
        }

    return occlusionProbes;
}

void SampleSkyOcclusion_float(float3 positionRWS, out float grassOcclusion, out float skyOcclusion)
{
    float3 positionWS = GetAbsolutePositionWS(positionRWS);
    grassOcclusion = SampleGrassOcclusion(positionWS);
    skyOcclusion = lerp(1.0, grassOcclusion * SampleOcclusionProbes(positionWS), _OcclusionProbesReflectionOcclusionAmount);
}

void SampleSkyOcclusionTerrain_float(float3 positionRWS, float2 terrainUV, out float grassOcclusion, out float skyOcclusion)
{
    float3 positionWS = GetAbsolutePositionWS(positionRWS);
    grassOcclusion = SampleGrassOcclusion(terrainUV);
    skyOcclusion = lerp(1.0, grassOcclusion * SampleOcclusionProbes(positionWS), _OcclusionProbesReflectionOcclusionAmount);
}

//forest-end: sky occlusion

//forest-begin: Tree occlusion

//UnityPerMaterial

//float4 treeAO: combined of:
//float _UseTreeOcclusion;
//float _TreeAO;
//float _TreeAOBias;
//float _TreeAO2;
//float _TreeAOBias2;

//float4 _TreeDO: combined of:
//float _TreeDO;
//float _TreeDOBias;
//float _TreeDO2;
//float _TreeDOBias2;

//float _Tree12Width;

void GetTreeOcclusion_float(float3 positionRWS, float4 treeOcclusionInput, float4 treeAOs, float4 treeDOs, float tree12Width, out float treeOcclusion) {
#if defined(_ANIM_SINGLE_PIVOT_COLOR) || defined(_ANIM_HIERARCHY_PIVOT)
        float _TreeAO = treeAOs.x;
        float _TreeAOBias = treeAOs.y;
        float _TreeAO2 = treeAOs.z;
        float _TreeAOBias2 = treeAOs.w;

        float _TreeDO = treeDOs.x;
        float _TreeDOBias = treeDOs.y;
        float _TreeDO2 = treeDOs.z;
        float _TreeDOBias2 = treeDOs.w;

        float _Tree12Width = tree12Width;

		float3 positionWS = GetAbsolutePositionWS(positionRWS);
		float treeWidth = _Tree12Width == 0 ? 1.f : saturate((positionWS.y - UNITY_MATRIX_M._m13) / _Tree12Width);
		float treeDO = lerp(_TreeDO, _TreeDO2, treeWidth);
		float treeAO = lerp(_TreeAO, _TreeAO2, treeWidth);
		float4 lightDir = float4(-_DirectionalLightDatas[0].forward * treeDO, treeAO);
		float treeDOBias = lerp(_TreeDOBias, _TreeDOBias2, treeWidth);
		float treeAOBias = lerp(_TreeAOBias, _TreeAOBias2, treeWidth);
		treeOcclusion = saturate(dot(saturate(treeOcclusionInput + float4(treeDOBias.rrr, treeAOBias)), lightDir));
#else
		treeOcclusion = 1.f;
#endif
}
//forest-end:




#ifndef UNITY_COMMON_MATERIAL_INCLUDED

// From CommonMaterial.hlsl
real PerceptualSmoothnessToRoughness(real perceptualSmoothness)
{
    return (1.0 - perceptualSmoothness) * (1.0 - perceptualSmoothness);
}
#endif // UNITY_COMMON_MATERIAL_INCLUDED

// From CommonLighting.hlsl
#ifndef UNITY_COMMON_LIGHTING_INCLUDED

// Based on Oat and Sander's 2008 technique
// Area/solidAngle of intersection of two cone
real SphericalCapIntersectionSolidArea(real cosC1, real cosC2, real cosB)
{
    real r1 = FastACos(cosC1);
    real r2 = FastACos(cosC2);
    real rd = FastACos(cosB);
    real area = 0.0;

    if (rd <= max(r1, r2) - min(r1, r2))
    {
        // One cap is completely inside the other
        area = TWO_PI - TWO_PI * max(cosC1, cosC2);
    }
    else if (rd >= r1 + r2)
    {
        // No intersection exists
        area = 0.0;
    }
    else
    {
        real diff = abs(r1 - r2);
        real den = r1 + r2 - diff;
        real x = 1.0 - saturate((rd - diff) / den);
        area = smoothstep(0.0, 1.0, x);
        area *= TWO_PI - TWO_PI * max(cosC1, cosC2);
    }

    return area;
}
#endif // UNITY_COMMON_LIGHTING_INCLUDED

// From LitData.hlsl

//float GetSpecularOcclusionFromBentAO(float3 V, float3 bentNormalWS, SurfaceData surfaceData)
void GetSpecularOcclusionFromBentAO_float(float3 V, float3 bentNormalWS, float ambientOcclusion, float perceptualSmoothness, float3 normalWS, out float specularOcclusion)
{
    // Retrieve cone angle
    // Ambient occlusion is cosine weighted, thus use following equation. See slide 129
    float cosAv = sqrt(1.0 - ambientOcclusion);
    float roughness = max(PerceptualSmoothnessToRoughness(perceptualSmoothness), 0.01); // Clamp to 0.01 to avoid edge cases
    float cosAs = exp2((-log(10.0)/log(2.0)) * Sq(roughness));
    float cosB = dot(bentNormalWS, reflect(-V, normalWS));

    specularOcclusion = SphericalCapIntersectionSolidArea(cosAv, cosAs, cosB) / (TWO_PI * (1.0 - cosAs));
}


#endif //FILE_FOREST_COMMON