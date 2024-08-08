using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.HighDefinition;

[ExecuteAlways]
public class LightPropertiesTarget : MonoBehaviour
{
    public static Light Instance;
    public static HDAdditionalLightData InstanceHD;

    void OnEnable()
    {
        Instance = GetComponent<Light>();
        InstanceHD = GetComponent<HDAdditionalLightData>();
    }
}
