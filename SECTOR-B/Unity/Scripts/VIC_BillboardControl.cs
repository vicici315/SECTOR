using UnityEngine;
using System.Collections;

public class VIC_BillboardControl : MonoBehaviour
{
	public GameObject obj;
	public float _rotateSpeed;
	public bool lockX;
	public bool lockY;
	public bool lockZ;
	private Vector3 oldRot;
	void Start(){
		oldRot = transform.localEulerAngles;
	}
    // Update is called once per frame  
    void Update()
    {	//计算目标与自身的旋转方向
		Vector3 RR = Camera.main.transform.position - transform.position;
		//定义四元素旋转为指向目标旋转
		Quaternion Rtarget = Quaternion.LookRotation(RR);
		//无过度旋转
		transform.rotation = Rtarget;
		//过度变化旋转
		// transform.rotation = Quaternion.Slerp(transform.rotation, Rtarget, Time.deltaTime * _rotateSpeed);
		//记录原始旋转
		Vector3 r = transform.localEulerAngles;
		if (lockX)
			r.x = oldRot.x;
		if (lockY)
			r.y = oldRot.y;
		if (lockZ)
			r.z = oldRot.z;
		//根据轴向判断恢复到原旋转参数
		transform.localEulerAngles = r;
    }
}