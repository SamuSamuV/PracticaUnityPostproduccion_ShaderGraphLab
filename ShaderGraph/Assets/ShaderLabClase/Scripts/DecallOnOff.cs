using UnityEngine;
using UnityEngine.InputSystem;

[ExecuteAlways]
public class DecallOnOff : MonoBehaviour
{
    private Material material;
    private bool showDecal = false;

    void Start()
    {
        material = GetComponent<Renderer>().material;
    }

    //private void Update()
    //{
    //    if (Mouse.current.leftButton.wasPressedThisFrame)
    //    {
    //        // will work with the new Input System
    //        RaycastHit hit;
    //        Ray ray = Camera.main.ScreenPointToRay(Mouse.current.position.ReadValue());
    //        if (Physics.Raycast(ray, out hit))
    //        {
    //            if (hit.transform == transform)
    //            {
    //                ToggleShowDecal();
    //            }
    //        }
    //    }
    //}

    public void ToggleShowDecal()
    {
        showDecal = !showDecal;
        if (showDecal)
            material.SetFloat("_ShowDecal", 1);
        else
            material.SetFloat("_ShowDecal", 0);
    }

    public void OnMouseDown()
    {
        // will work ONLY with the old Input System
        ToggleShowDecal();
    }

    private void OnDestroy()
    {
        DestroyImmediate(material);
    }
}
