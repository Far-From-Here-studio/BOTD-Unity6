using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.HighDefinition;

[ExecuteAlways]
[RequireComponent(typeof(HDAdditionalLightData))]
public class StaggeredCascade : MonoBehaviour
{
    public enum Mode
    {
        None = -1,
        Full0Alt12Fix3 = 0,
        Full01Alt23 = 1,
        Full012Fix3 = 2,
    }

    public Mode mode;

    HDAdditionalLightData lightData;

    void Awake()
    {
        lightData = GetComponent<HDAdditionalLightData>();
#if !UNITY_EDITOR
#if UNITY_XBOXONE
        if (mode == Mode.Full012Fix3)
        {
            // On base H/W, force the shadows to alternate cascades 2/3 for performance
            UnityEngine.XboxOne.HardwareVersion hwVersion = UnityEngine.XboxOne.Hardware.version;
            if ((hwVersion == UnityEngine.XboxOne.HardwareVersion.XboxOne) || (hwVersion == UnityEngine.XboxOne.HardwareVersion.XboxOneS))
            {
                mode = Mode.Full0Alt12Fix3;
            }
        }
#endif
#endif
    }

    void Update()
    {
        switch (mode)
        {
            case Mode.None:
                break;
            case Mode.Full0Alt12Fix3:
                lightData.RequestSubShadowMapRendering(0);
                lightData.RequestSubShadowMapRendering(Time.frameCount % 2 == 0 ? 1 : 2);
                break;
            case Mode.Full01Alt23:
                lightData.RequestSubShadowMapRendering(0);
                lightData.RequestSubShadowMapRendering(1);
                lightData.RequestSubShadowMapRendering(Time.frameCount % 2 == 0 ? 2 : 3);
                break;
            case Mode.Full012Fix3:
                lightData.RequestSubShadowMapRendering(0);
                lightData.RequestSubShadowMapRendering(1);
                lightData.RequestSubShadowMapRendering(2);
                break;
        }
    }
}