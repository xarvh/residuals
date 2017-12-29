using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class GroundCheck : MonoBehaviour {

  // public
  public LayerMask GroundLayerMask;
  public LayerMask PlatformLayerMask;

  public bool IsGrounded() {
    return EnteredGroundObjects.Count > 0 || EnteredPlatformObjects.Count > 0;
  }

  public bool IsGroundedOnPlatform() {
    return EnteredGroundObjects.Count == 0 && EnteredPlatformObjects.Count > 0;
  }

  // private
  HashSet<GameObject> EnteredGroundObjects = new HashSet<GameObject>();
  HashSet<GameObject> EnteredPlatformObjects = new HashSet<GameObject>();


  // inherited
  void OnTriggerEnter2D(Collider2D other) {
    if (IsInLayerMask(other.gameObject.layer, GroundLayerMask)) {
      EnteredGroundObjects.Add(other.gameObject);
    }

    if (IsInLayerMask(other.gameObject.layer, PlatformLayerMask)) {
      EnteredPlatformObjects.Add(other.gameObject);
    }
  }

  void OnTriggerExit2D(Collider2D other) {
    if (IsInLayerMask(other.gameObject.layer, GroundLayerMask)) {
      EnteredGroundObjects.Remove(other.gameObject);
    }

    if (IsInLayerMask(other.gameObject.layer, PlatformLayerMask)) {
      EnteredPlatformObjects.Remove(other.gameObject);
    }
  }


  // TODO: move this to a helper class
  bool IsInLayerMask(int layer, LayerMask layermask) {
    return layermask == (layermask | (1 << layer));
  }
}
