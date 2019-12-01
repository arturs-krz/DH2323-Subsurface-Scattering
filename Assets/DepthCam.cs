using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class DepthCam : MonoBehaviour
{
    public Shader depthShader;

    private RenderTexture targetTexture;
    private Camera depthCam;

    // Start is called before the first frame update
    void Start()
    {
        depthCam = GetComponent<Camera>();

        targetTexture = new RenderTexture(depthCam.pixelWidth, depthCam.pixelHeight, 24, RenderTextureFormat.ARGBFloat);
        targetTexture.name = "Depth Texture";
        targetTexture.Create();
        depthCam.targetTexture = targetTexture;
        //SetShaderProps();

        if (depthShader != null)
        {
            depthCam.SetReplacementShader(depthShader, "RenderType");
        }
    }

    // Update is called once per frame
    void Update()
    {
        SetShaderProps();
    }

    void OnDestroy()
    {
        targetTexture.Release();    
    }

    void SetShaderProps()
    {
        Matrix4x4 lightV = depthCam.worldToCameraMatrix;
        Matrix4x4 lightP = depthCam.projectionMatrix;

        bool d3d = SystemInfo.graphicsDeviceVersion.IndexOf("Direct3D") > -1;
        if (d3d)
        {
            // Invert Y for rendering to a render texture
            for (int i = 0; i < 4; i++)
            {
                lightP[1, i] = -lightP[1, i];
            }
            // Scale and bias from OpenGL -> D3D depth range
            for (int i = 0; i < 4; i++)
            {
                lightP[2, i] = lightP[2, i] * 0.5f + lightP[3, i] * 0.5f;
            }
        }
        
        Shader.SetGlobalMatrix("_DepthCamV", lightV);
        Shader.SetGlobalMatrix("_DepthCamP", lightP);
        Shader.SetGlobalTexture("_DepthTexz", depthCam.targetTexture);
    }
}
