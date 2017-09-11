using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CubemapCreator : MonoBehaviour
{
    [SerializeField]
    bool oneFacePerFrame;

    Camera cam;

    Cubemap cubemap;

    Material mat;

    void Start()
    {
        mat = GetComponent<Renderer>().sharedMaterial;
        cubemap = mat.GetTexture("_Cubemap") as Cubemap;

        GameObject go = new GameObject("CubemapCamera", typeof(Camera));
        go.hideFlags = HideFlags.HideAndDontSave;
        go.transform.position = transform.position;
        go.transform.rotation = Quaternion.identity;
        cam = go.GetComponent<Camera>();
        cam.farClipPlane = 100;
        cam.enabled = false;
    }

    void LateUpdate()
    {
        if (oneFacePerFrame)
        {
            var faceToRender = Time.frameCount % 6;
            var faceMask = 1 << faceToRender;
            UpdateCubemap(faceMask);
        }
        else
        {
            UpdateCubemap(63); // all six faces
        }
    }

    void UpdateCubemap(int faceMask)
    {
        cam.transform.position = transform.position;
        cam.RenderToCubemap(cubemap, faceMask);
        mat.SetTexture("_Cubemap", cubemap);
    }
}
