//获取material贴图进行UV游走动画
_lineRender.material.mainTextureOffset = new Vector2(-offisetSpeed * Time.time, 0);
//修改用户自定义Shader属性，运用SetTextureOffset() 输入属性名称字符"_Diffuse"
_lineRender.material.SetTextureOffset("_Diffuse", new Vector2(-offisetSpeed * Time.time, 0));

//时间间隔执行，值越大间隔越久（整数int）
if ((Time.frameCount % 8) == 0){...}

//随机值，Random来源于UnityEngine(新版Unity)
UnityEngine.Random.value;	//返回0到1间的随机浮点数
UnityEngine.Random.Range(0, 12);	//返回两个值间的整数
UnityEngine.Random.Range(0f, 12f);	//返回两个值间的浮点数

//添加到Unity菜单，写在public class EnemySpawn : MonoBehaviour {}上方
[AddComponentMenu("WOU/Enemy_Spawn")]

//判断鼠标在屏幕中点击
if (Input.GetMouseButtonDown(0))
{
	float randomVal = UnityEngine.Random.Range(0f,12f);
	Debug.Log("  随机数  " + randomVal);
}

