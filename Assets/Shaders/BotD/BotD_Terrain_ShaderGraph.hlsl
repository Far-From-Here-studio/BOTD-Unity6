// Returns layering blend mask after application of height based blend.
float4 ApplyHeightBlend(float4 heights, float4 blendMask, float heightTransition)
{
    // We need to mask out inactive layers so that their height does not impact the result.
    float4 maskedHeights = heights * blendMask.argb;

    float maxHeight = max(max(max(maskedHeights.x, maskedHeights.y), maskedHeights.z), maskedHeights.w);
    // Make sure that transition is not zero otherwise the next computation will be wrong.
    // The epsilon here also has to be bigger than the epsilon in the next computation.
    float transition = max(heightTransition, 1e-5);

    // The goal here is to have all but the highest layer at negative heights, then we add the transition so that if the next highest layer is near transition it will have a positive value.
    // Then we clamp this to zero and normalize everything so that highest layer has a value of 1.
    maskedHeights = maskedHeights - maxHeight.xxxx;
    // We need to add an epsilon here for active layers (hence the blendMask again) so that at least a layer shows up if everything's too low.
    maskedHeights = (max(0, maskedHeights + transition) + 1e-6) * blendMask.argb;

    // Normalize
    maxHeight = max(max(max(maskedHeights.x, maskedHeights.y), maskedHeights.z), maskedHeights.w);
    maskedHeights = maskedHeights / max(maxHeight.xxxx, 1e-6);

    return maskedHeights.yzwx;
}

void ComputeMaskWeights(float4 inputMasks, out float outWeights[4])
{
    ZERO_INITIALIZE_ARRAY(float, outWeights, 4);

    float masks[4];
    masks[0] = inputMasks.a;
    masks[1] = inputMasks.r;
    masks[2] = inputMasks.g;
    masks[3] = inputMasks.b;

    // calculate weight of each layers
    // Algorithm is like this:
    // Top layer have priority on others layers
    // If a top layer doesn't use the full weight, the remaining can be use by the following layer.
    float weightsSum = 0.0;

    UNITY_UNROLL
    for (int i = 3; i >= 0; --i)
    {
        outWeights[i] = min(masks[i], (1.0 - weightsSum));
        weightsSum = saturate(weightsSum + masks[i]);
    }
}

void ComputeLayerWeights_float(float4 sampledHeights, float4 blendMasks, float heightTransition, out float4 layerWeights)
{
    // Modify blendMask to take into account the height of the layer. Higher height should be more visible.
    blendMasks = ApplyHeightBlend(sampledHeights, blendMasks, heightTransition);
    float outWeights[4];
    ComputeMaskWeights(blendMasks, outWeights);
    layerWeights.x = outWeights[0];
    layerWeights.y = outWeights[1];
    layerWeights.z = outWeights[2];
    layerWeights.w = outWeights[3];
}