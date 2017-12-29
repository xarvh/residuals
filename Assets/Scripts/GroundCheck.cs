using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class GroundCheck : MonoBehaviour {

  // public
  public LayerMask GroundLayerMask;

  public bool IsGrounded() {
    return EnteredGroundObjects.Count > 0;
  }


  // private
  HashSet<GameObject> EnteredGroundObjects = new HashSet<GameObject>();


  // inherited
  void OnTriggerEnter2D(Collider2D other) {
    if (IsInLayerMask(other.gameObject.layer, GroundLayerMask)) {
      EnteredGroundObjects.Add(other.gameObject);
    }
  }

  void OnTriggerExit2D(Collider2D other) {
    if (IsInLayerMask(other.gameObject.layer, GroundLayerMask)) {
      EnteredGroundObjects.Remove(other.gameObject);
    }
  }


  // TODO: move this to a helper class
  bool IsInLayerMask(int layer, LayerMask layermask) {
    return layermask == (layermask | (1 << layer));
  }
}
