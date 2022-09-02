using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class MeshSequenceFrame : MonoBehaviour
{

	public Mesh[] AllMesh;
	private MeshFilter _meshFilter;
    public float IndexFrame; //动画传入的必须是Float类型
    public int Index;
   
    void Awake()
	{      

    }

	void Update()
	{
     
        Index = (int)IndexFrame; //转换为Int 
        Refresh();  
    }

    private void Refresh()
	{
        if (AllMesh == null || AllMesh.Length == 0)
        {
            //防止数组为0抛异常
            return;
        }
        if (!_meshFilter)
        {
            _meshFilter = GetComponent<MeshFilter>();
        }

        Index = Mathf.Clamp(Index, 0, AllMesh.Length - 1); //将值限制在数组内的个数

		_meshFilter.mesh = AllMesh[Index];
	}


    

}
