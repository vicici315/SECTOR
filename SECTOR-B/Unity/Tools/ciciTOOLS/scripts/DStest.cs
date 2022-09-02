using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
public class DStest : MonoBehaviour
{
    WindowData windowData;
    public bool displaySphere = false;
    public bool displayLine = true;
    public bool reflashLine = true;
    public List<GameObject> createObjs = new List<GameObject>();
    [RangeAttribute(0, 300)]
    public int rejectionSamples = 30;
    [RangeAttribute(0.2f, 6)] [Tooltip("sample Radius")]
    public float sampleRadius = 1;

    public float rayDistance = 1;
    [RangeAttribute(0.0f, 15)]
    public float lineLangth = 0.02f;
    [HideInInspector]
    public GameObject shapeMeshOjb;
    
    [RangeAttribute(0.0f, 1.0f)]
    public float Direction_Normal=0;
    [Tooltip("不旋转的轴值设为 0")]
    public Vector3 rotation = new Vector3(0, 0, 0);
    public Vector3 randomRotation = new Vector3(0, 0, 0);
    public Vector2 randomScaleMinMax = new Vector2(1, 1);
    private int activeLayers = (1<<5);

    private List<GameObject> confirmObjs;
    private List<Vector2> points;
    private List<GameObject> GObj = new List<GameObject>();
    
    public void OnValidate()
    {
        MeshFilter mf;
        try { mf = shapeMeshOjb.transform.GetComponent<MeshFilter>(); } catch { mf = null; }
        if (mf != null)
        try{
            Vector2 Mes = new Vector2(mf.sharedMesh.bounds.size.x, mf.sharedMesh.bounds.size.z);
            points = DiscSampling.GeneratePoints(sampleRadius, Mes, rejectionSamples);
            }
            catch { }
        if (randomScaleMinMax.x > randomScaleMinMax.y)
            randomScaleMinMax.x = randomScaleMinMax.y;
    }
    public void OnDrawGizmos()
    {
        if (points != null)
        {
            foreach (Vector2 point in points)
            {
                Vector3 pos = new Vector3(point.x, rayDistance, point.y) + shapeMeshOjb.transform.position + shapeMeshOjb.transform.GetComponent<MeshCollider>().sharedMesh.bounds.min;
                Ray ray = new Ray(pos, Vector3.down);
                RaycastHit hit;
                if (Physics.Raycast(ray, out hit, rayDistance + lineLangth, activeLayers))
                {
                    if (displaySphere)
                        Gizmos.DrawSphere(pos, randomScaleMinMax.y / 2);
                    if (displayLine)
                        Debug.DrawLine(pos, pos + Vector3.down * (rayDistance + lineLangth), Color.red);
                }
            }
        }
    }
    public void DelAbc()
    {
                    if (GObj.Count != 0)
                    {
                        foreach (GameObject o in GObj)
                        {
                            DestroyImmediate(o);
                        }
            GObj = new List<GameObject>();
                    }
    }
    public void ConfirmAbc()
    {
        if (GObj.Count != 0)
        {
            if (windowData == null)
            {
                windowData = new WindowData();
            }
            windowData.Confirm = new List<GameObject>();
            int c = 0;
            GameObject pp = new GameObject();
            int pc = 1;
            while (GameObject.Find("Confirm_"+pc.ToString())!=null)
            {
                pc++;
            }
            pp.name = "Confirm_" + pc;
            foreach (GameObject o in GObj)
            {
                o.transform.parent = pp.transform;
                o.name += "_confirm";
                c++;
                windowData.Confirm.Add(o);
                windowData.AllConfirms.Add(o);
            }
            GObj = new List<GameObject>();
        }
    }
    public void SelConfirm()
    {
        if (windowData.Confirm.Count > 0)
            Selection.objects = windowData.Confirm.ToArray();
    }
    public void SelAllCon()
    {
        if (windowData.AllConfirms.Count > 0)
        {
            confirmObjs = new List<GameObject>();
            foreach (GameObject o in windowData.AllConfirms)
            {
                if (o != null)
                {
                    confirmObjs.Add(o);
                }
            }
            Selection.objects = confirmObjs.ToArray();
        }
    }
    public void Abc()
    {
                    if (GObj.Count != 0)
                    {
                        foreach (GameObject o in GObj)
                        {
                            DestroyImmediate(o);
                        }
            GObj = new List<GameObject>();
                    }
        MeshCollider mf = shapeMeshOjb.transform.GetComponent<MeshCollider>();
        int cc = 1;
        foreach (Vector2 point in points)
        {
            Vector3 pos = new Vector3(point.x, rayDistance, point.y) + shapeMeshOjb.transform.position + mf.sharedMesh.bounds.min; // bounds.min为模型边界坐标
            Ray ray = new Ray(pos, Vector3.down);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit, rayDistance + lineLangth, activeLayers))
            {
                if (createObjs.Count >= 1)
                {
                    Quaternion Orientation = new Quaternion(0, 0, 0, 1);

                    float RS = Random.Range(randomScaleMinMax.x, randomScaleMinMax.y);
                    Orientation = Quaternion.Slerp(Quaternion.identity, Quaternion.LookRotation(hit.normal), Direction_Normal);
                    int ramV = Random.Range(0,createObjs.Count);
                    GameObject nb = Instantiate(createObjs[ramV], hit.point, Orientation);
                    nb.transform.localScale = new Vector3(RS, RS, RS);
                    nb.transform.localEulerAngles += new Vector3(Random.Range(-randomRotation.x, randomRotation.x), Random.Range(-randomRotation.y, randomRotation.y), Random.Range(-randomRotation.z, randomRotation.z)) + rotation;
                    nb.transform.parent = transform;
                    nb.name += cc.ToString();
                    cc++;
                    GObj.Add(nb);
                }
            }
        }
    }
    public void RotClone()
    {
         if (GObj.Count >= 1)
        {
            foreach(GameObject o in GObj)
            {
                /*
                                if(randomRotation.x != 0)
                                    o.transform.rotation = Quaternion.AngleAxis(Random.Range(-randomRotation.x, randomRotation.x),new Vector3(1, 0, 0));
                                if(randomRotation.y != 0)
                                    o.transform.rotation = Quaternion.AngleAxis(Random.Range(-randomRotation.y, randomRotation.y),new Vector3(0, 1, 0));
                                if(randomRotation.z != 0)
                                    o.transform.rotation = Quaternion.AngleAxis(Random.Range(-randomRotation.z, randomRotation.z),new Vector3(0, 0, 1));
                */
                o.transform.localEulerAngles += new Vector3(Random.Range(-randomRotation.x, randomRotation.x), Random.Range(-randomRotation.y, randomRotation.y), Random.Range(-randomRotation.z, randomRotation.z));

            }
        }
    }

}
