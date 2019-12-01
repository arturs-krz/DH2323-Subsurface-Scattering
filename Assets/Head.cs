using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;
public class Head : MonoBehaviour
{
    public Slider rotationSlider;
    private bool isManuallyRotated = false;
    private Vector3 initAngles;

    void Start()
    {
        initAngles = transform.rotation.eulerAngles;
    }


    // Update is called once per frame
    void Update()
    {
        //Debug.Log(rotationSlider.value);
        //transform.Rota
        //transform.localRotation = Quaternion.Euler(0, 0, rotationSlider.value * 360f);
        //if (!isManuallyRotated)
        //{
        //    transform.Rotate(Time.deltaTime * new Vector3(0, 0, 5f));
        //}
    }

    public void OnChangeRotation()
    {
        transform.rotation = Quaternion.Euler(initAngles.x, rotationSlider.value * 360f, initAngles.z);
    }

    //private void OnMouseDown()
    //{
    //    isManuallyRotated = true;
    //}

    //private void OnMouseDrag()
    //{
    //    //Debug.Log("DOWN");
    //    float rotation = Input.GetAxis("Mouse Y");
    //    transform.Rotate(new Vector3(0, 0, -5f * rotation));
    //}

    //private void OnMouseUp()
    //{
    //    isManuallyRotated = false;
    //}

}
