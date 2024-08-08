using UnityEngine;
using Unity.Collections;
using Unity.Jobs;
using System.Collections.Generic;
using System.Linq;

[ExecuteAlways]
public class RotationSlerper : MonoBehaviour
{
    // Reference transform whose rotation will be used
    public Transform referenceTransform;

    // List of transforms to slerp their rotation
    List<Transform> transformsToSlerp;

    // Speed of rotation interpolation
    public float rotationSpeed = 2f;

    // Native array to store the rotations
    NativeArray<Quaternion> targetRotations;

    // Job handle to manage the rotation job
    RotationSlerpJob rotationJob;
    JobHandle rotationJobHandle;

    void OnEnable()
    {
        // Allocate memory for the native array
       
        transformsToSlerp = new List<Transform>();

        var LocalfogwithWind = FindObjectsByType<VolumetricMaterialPropertiesBinder>(FindObjectsSortMode.None);
        foreach (var kvp in LocalfogwithWind)
        {
            if (!transformsToSlerp.Contains(kvp.gameObject.transform) && kvp.UseWindDirection == true)
            {
                transformsToSlerp.Add(kvp.gameObject.transform);
            }
        }
        targetRotations = new NativeArray<Quaternion>(transformsToSlerp.Count, Allocator.Persistent);
    }

    void OnDestroy()
    {
        // Release memory when the script is destroyed
        //targetRotations.Dispose();
    }
    void OnDisable()
    {
        // Release memory when the script is destroyed
        targetRotations.Dispose();
    }

    void Update()
    {
        // If the reference transform is not assigned, exit the method
        if (referenceTransform == null)
        {
            Debug.LogError("Reference Transform is not assigned!");
            return;
        }



        // Update the native array with the target rotations
        for (int i = 0; i < transformsToSlerp.Count; i++)
        {
            targetRotations[i] = transformsToSlerp[i].rotation;
        }

        // Create and schedule the rotation job
        rotationJob = new RotationSlerpJob
        {
            referenceRotation = referenceTransform.rotation,
            targetRotations = targetRotations,
            rotationSpeed = rotationSpeed * Time.deltaTime
        };

        rotationJobHandle = rotationJob.Schedule(transformsToSlerp.Count, 32);

        // Ensure the rotation job is completed before the next frame
        rotationJobHandle.Complete();

        // Update the rotations of the transforms with the job results
        for (int i = 0; i < transformsToSlerp.Count; i++)
        {
            transformsToSlerp[i].rotation = targetRotations[i];
        }
    }

    // Job struct for performing rotation slerp
    struct RotationSlerpJob : IJobParallelFor
    {
        [ReadOnly] public Quaternion referenceRotation;
        public NativeArray<Quaternion> targetRotations;
        public float rotationSpeed;

        public void Execute(int index)
        {
            // Slerp the rotation of the target transform towards the reference transform's rotation
            targetRotations[index] = Quaternion.Slerp(targetRotations[index], referenceRotation, rotationSpeed);
        }
    }
}
