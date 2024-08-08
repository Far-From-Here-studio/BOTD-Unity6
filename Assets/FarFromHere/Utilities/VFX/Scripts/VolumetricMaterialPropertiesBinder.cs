using UnityEngine;
using UnityEngine.Rendering.HighDefinition;

#if UNITY_EDITOR
using UnityEditor;
#endif


[System.Serializable]
public struct VM_FloatProperty
{
    public string PropertyName;
    public float floatValue;
}

[System.Serializable]
public struct VM_TextureProperty
{
    public string PropertyName;
    public Texture3D texture3DValue;
}

[System.Serializable]
public struct VM_VectorProperty
{
    public string PropertyName;
    public Vector4 vector4Value;
}


[ExecuteAlways]
public class VolumetricMaterialPropertiesBinder : MonoBehaviour
{
    private Material VolumetricMaterial;
    private Transform fogvolume;

    public VM_FloatProperty[] floatProperties;
    public VM_TextureProperty[] textureProperties;
    public VM_VectorProperty[] vectorProperties;

    public bool setObjectPosition;
    public bool needCustomProperties = false;
    public bool UseWindDirection = false;

    private void Awake()
    {
        fogvolume = GetComponent<LocalVolumetricFog>().gameObject.transform;
        var mat = GetComponent<LocalVolumetricFog>().parameters.materialMask;
        var NewFogMaterial = new Material(mat);
        NewFogMaterial = mat;
        VolumetricMaterial = NewFogMaterial;
        GetComponent<LocalVolumetricFog>().parameters.materialMask = NewFogMaterial;
    }

    private void LateUpdate()
    {
        if(setObjectPosition) VolumetricMaterial.SetVector("_ObjectPos", fogvolume.position);
        if (UseWindDirection)
        {
            var winddirection = Shader.GetGlobalVector("_WindOrientation");
            var windforce = Shader.GetGlobalFloat("_WindForce");
            VolumetricMaterial.SetVector("_WindDirection", winddirection);
            VolumetricMaterial.SetFloat("_WindForce", windforce);
        }

        if (!needCustomProperties) return;
        foreach (var properties in floatProperties)
        {
            VolumetricMaterial.SetFloat(properties.PropertyName, properties.floatValue);
        }
        foreach (var properties in textureProperties)
        {
            VolumetricMaterial.SetTexture(properties.PropertyName, properties.texture3DValue);
        }
        foreach (var properties in vectorProperties)
        {
            VolumetricMaterial.SetVector(properties.PropertyName, properties.vector4Value);
        }
    }
}