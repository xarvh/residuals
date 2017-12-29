using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement; // include so we can load new scenes

public class CharacterController2D : MonoBehaviour {

  //[Range(0.001f, 10.0f)]
  float WalkMaximumSpeed = 2.5f;

  //[Range(0.0f, 20.0f)]
  float JumpForce = 400f;

  //
  public GameObject GroundCheckObject;
  GroundCheck GroundCheckScript;

  // private stuff
  float InputMoveX = 0;
  bool InputJump = false;
  bool InputVernier = false;
  Transform Transform;
  Rigidbody2D Rigidbody;
  int PlatformCollisionLayer;


  void Awake () {
    // get a reference to the components we are going to be changing and store a reference for efficiency purposes
    Transform = GetComponent<Transform>();

    Rigidbody = GetComponent<Rigidbody2D>();
    if (Rigidbody == null) throw new System.ArgumentNullException("No Rigidbody2D");

    // determine the platform's specified layer
    PlatformCollisionLayer = LayerMask.NameToLayer("Platform");
    //Debug.Log(PlatformCollisionLayer);

    if (GroundCheckObject == null) throw new System.ArgumentNullException("No GroundCheck");
    GroundCheckScript = GroundCheckObject.GetComponent<GroundCheck>();
    if (GroundCheckScript == null) throw new System.ArgumentNullException("No GroundCheckScript");
  }


  void FixedUpdate()
  {
    InputMoveX = Input.GetAxisRaw("Horizontal");
    InputJump = Input.GetButtonDown("Jump");
    InputVernier = Input.GetButtonDown("Fire3");

    bool isGrounded = GroundCheckScript.IsGrounded();

    /*
    https://answers.unity.com/questions/1333301/visualize-boxcast-rect.html
    IsGrounded = Physics2D.BoxCast(
        Vector2.down
        new Vector2(0.99, 0.01),
        GroundLayerMask);
    */

    float vx = Rigidbody.velocity.x;
    //float vy = Rigidbody.velocity.y;

    // Walk
    if (isGrounded) {
      float limiter =
        vx * InputMoveX < 0
        // acceleration is opposite to velocity, no limitation needed
        ? InputMoveX
        // acceleration will increase velocity, needs to be limited
        : (1 - Mathf.Abs(vx) / WalkMaximumSpeed) * InputMoveX;

      float walkForce = WalkMaximumSpeed * 4;

      Rigidbody.AddForce(Transform.right * walkForce * limiter);
    }

    // Jump
    if (isGrounded && InputJump) {
      Rigidbody.AddForce(Transform.up * JumpForce);
    }

    // if moving up then don't collide with platform layer
    // this allows the player to jump up through things on the platform layer
    // NOTE: requires the platforms to be on a layer named "Platform"
    //
    // TODO Physics2D.IgnoreLayerCollision(this.gameObject.layer, PlatformCollisionLayer, (vy > 0.0f));
  }
}
