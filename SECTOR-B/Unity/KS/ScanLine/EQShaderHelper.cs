using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
namespace Debrion
{
    public class EQShaderHelper : MonoBehaviour
    {
        #region Variables
        protected Material _material = null;
        #endregion

        #region Properties
        public GameObject target;
		public int materialId = 0;
		public Vector3 offset;
		public Vector3 scaleValue;
        public float sphereSize=0.1f;
        #endregion

        #region Methods
        // Use this for initialization
        void Start()
        {
            if(target != null)
            {
				_material = target.GetComponent<Renderer>().materials[materialId];
            }
        }

        // Update is called once per frame
        void Update()
        {
            if (_material == null)
                return;

            Vector3 pos = transform.localPosition;
			_material.SetVector("_SphereCenter", new Vector4(-pos.y + offset.x, pos.z + offset.y, -pos.x + offset.z, 0));
			_material.SetVector("_Scale", new Vector4(scaleValue.x,scaleValue.y,scaleValue.z, 0));
		}

#if UNITY_EDITOR
        void OnDrawGizmos()
        {
            Gizmos.DrawSphere(transform.position, sphereSize);
			if(target != null )
			{
				Vector3 pos = transform.localPosition;
				Renderer rend = target.GetComponent<Renderer> ();
				if (rend != null) {
					Material mat = rend.materials [materialId];
					mat.SetVector("_SphereCenter", new Vector4(-pos.y + offset.x, pos.z + offset.y, -pos.x + offset.z, 0));
					mat.SetVector("_Scale", new Vector4(scaleValue.x,scaleValue.y,scaleValue.z, 0));
					//rend.sharedMaterial.SetVector ("_SphereCenter", new Vector4 (-pos.y + offset.x, pos.z + offset.y, -pos.x + offset.z, 0));
					//rend.sharedMaterial.SetVector ("_Scale", new Vector4 (scaleValue.x, scaleValue.y, scaleValue.z, 0));
				}
			}
        }
#endif
        #endregion
    }
}
