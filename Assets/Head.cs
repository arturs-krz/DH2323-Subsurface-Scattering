using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class Head : MonoBehaviour
{
    private Renderer headRenderer;

    //public Light light;

    private RenderTexture depthTex;
    public Camera lightViewCamera;

    private bool ble = true;

    // Start is called before the first frame update
    void Start()
    {
        headRenderer = GetComponent<Renderer>();

        //RenderTexture secondary = new RenderTexture(lightViewCamera.pixelWidth, lightViewCamera.pixelHeight, 16, RenderTextureFormat.Default);
        //RenderTexture depth = new RenderTexture(lightViewCamera.pixelWidth, lightViewCamera.pixelHeight, 24, RenderTextureFormat.Depth);

        //lightViewCamera.depthTextureMode = DepthTextureMode.Depth;
        //lightViewCamera.SetTargetBuffers(secondary.colorBuffer, depth.depthBuffer);
        //Shader.SetGlobalTexture("_DepthTex", depth);

        if (lightViewCamera)
        {
            bool d3d = SystemInfo.graphicsDeviceVersion.IndexOf("Direct3D") > -1;
            Matrix4x4 modelMatrix = transform.localToWorldMatrix;
            Matrix4x4 lightV = lightViewCamera.worldToCameraMatrix;
            Matrix4x4 lightP = lightViewCamera.projectionMatrix;



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

            // Matrix4x4 lightMatrix = light.transform.worldToLocalMatrix;
            Matrix4x4 lightMatrix = lightP * lightV;

            if (!ble)
            {
                Debug.Log(lightV);
                Debug.Log(lightP);
                Debug.Log(lightP * lightV * modelMatrix);
                ble = true;
            }

            headRenderer.material.SetMatrix("_LightV", lightV);
            headRenderer.material.SetMatrix("_LightMV", lightV * modelMatrix);
            headRenderer.material.SetMatrix("_LightMVP", lightP * lightV * modelMatrix);
            headRenderer.material.SetMatrix("_LightMatrix", lightMatrix);
        }

        //AddBuffer();


        //Shader SSShader = headRenderer.material.shader;
        
    }

    private void OnValidate()
    {
        //if (Application.isPlaying)
        //{
        //    AddBuffer();
        //}
    }

    void AddBuffer()
    {
        //Debug.Log(step);
        //Camera.main.RemoveAllCommandBuffers();
        lightViewCamera.RemoveAllCommandBuffers();
        //int depthTexID = Shader.PropertyToID("_DepthTex");

        CommandBuffer buffer = new CommandBuffer();

        //buffer.GetTemporaryRT(depthTexID, -1, -1, 1, FilterMode.Bilinear, RenderTextureFormat.ARGB32);
        depthTex = new RenderTexture(lightViewCamera.pixelWidth, lightViewCamera.pixelHeight, 0);
        RenderTargetIdentifier depthTexID = new RenderTargetIdentifier(depthTex);
        buffer.SetRenderTarget(depthTexID);
        buffer.ClearRenderTarget(true, true, Color.clear, 1f);
        buffer.DrawRenderer(headRenderer, headRenderer.material, 0, 0);
        
        //buffer.Blit(BuiltinRenderTextureType.CurrentActive, depthTexID, headRenderer.material, 0);
        buffer.SetGlobalTexture("_DepthTex", depthTexID);
        //if (step == 0)
        //{
        //    buffer.Blit(depthTexID, BuiltinRenderTextureType.CameraTarget);
        //} else
        //{
        //    buffer.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
        //    buffer.DrawRenderer(headRenderer, headRenderer.material, 0, 1);
        //}


        //buffer.ReleaseTemporaryRT(depthTexID);

        //Camera.main.AddCommandBuffer(CameraEvent.AfterForwardAlpha, buffer);
        lightViewCamera.AddCommandBuffer(CameraEvent.AfterEverything, buffer);
        Debug.Log("Adding buffer");
    }

    //void OnRenderImage(RenderTexture src, RenderTexture dest)
    //{
    //    Graphics.Blit(depthTex, dest);
    //}

    // Update is called once per frame
    void Update()
    {
        if (lightViewCamera)
        {
            bool d3d = SystemInfo.graphicsDeviceVersion.IndexOf("Direct3D") > -1;
            Matrix4x4 modelMatrix = transform.localToWorldMatrix;
            Matrix4x4 lightV = lightViewCamera.worldToCameraMatrix;
            Matrix4x4 lightP = lightViewCamera.projectionMatrix;



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

            // Matrix4x4 lightMatrix = light.transform.worldToLocalMatrix;
            Matrix4x4 lightMatrix = lightP * lightV;

            if (!ble)
            {
                Debug.Log(lightV);
                Debug.Log(lightP);
                Debug.Log(lightP * lightV * modelMatrix);
                ble = true;
            }

            headRenderer.material.SetMatrix("_LightV", lightV);
            headRenderer.material.SetMatrix("_LightMV", lightV * modelMatrix);
            headRenderer.material.SetMatrix("_LightMVP", lightP * lightV * modelMatrix);
            headRenderer.material.SetMatrix("_LightMatrix", lightMatrix);
        }
    }

    void OnWillRenderObject()
    {
        
    }
}
