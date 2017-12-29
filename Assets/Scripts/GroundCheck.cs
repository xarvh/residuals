using System.Collections;
using System.Collections.Generic;
using UnityEngine;







public class GroundCheck : MonoBehaviour {


  public LayerMask GroundLayerMask;


  HashSet<GameObject> EnteredGroundObjects = new HashSet<GameObject>();


  bool IsInLayerMask(int layer, LayerMask layermask)
  {
    return layermask == (layermask | (1 << layer));
  }


  public bool IsGrounded() {
    return EnteredGroundObjects.Count > 0;
  }


  void OnTriggerEnter2D(Collider2D other) {
    if (IsInLayerMask(other.gameObject.layer, GroundLayerMask)) {
      EnteredGroundObjects.Add(other.gameObject);
      Debug.Log("Enter " + other.gameObject.name + " " + EnteredGroundObjects.Count);
    }
  }

  void OnTriggerExit2D(Collider2D other) {
    if (IsInLayerMask(other.gameObject.layer, GroundLayerMask)) {
      EnteredGroundObjects.Remove(other.gameObject);
      Debug.Log("Exit " + other.gameObject.name + " " + EnteredGroundObjects.Count);
    }
  }
}
