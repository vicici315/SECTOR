using System.Collections.Generic;
using UnityEngine;
using Sebastian.Geometry;
public class ShapeC : MonoBehaviour
{
    public GameObject meshObj;
    [HideInInspector]
    public List<Shape> shapes = new List<Shape>();

    [HideInInspector]
    public bool showShapesList;
    [RangeAttribute(0.1f, 2)]
    public float handleRadius = .2f;

    public void UpdateMeshDisplay()
    {
        CompositeShape compShape = new CompositeShape(shapes);
        meshObj.GetComponent<MeshFilter>().mesh = compShape.GetMesh();
        meshObj.GetComponent<MeshCollider>().sharedMesh = compShape.GetMesh(); //需要再使用GetMesh函数来获取Mesh，选定meshObj时才能看到碰撞体绿色线框
    }
}
