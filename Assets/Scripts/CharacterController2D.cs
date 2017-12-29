using UnityEngine;
using UnityEngine.Assertions;
using System.Collections;


public class CharacterController2D : MonoBehaviour {

  //
  // API
  //
  [Range(0.1f, 10.0f)]
  public float WalkMaximumSpeed = 4.5f;

  [Range(1f, 900.0f)]
  public float JumpForce = 300f;

  //
  public GameObject GroundCheckObject;
  GroundCheck GroundCheckScript;

  //
  // private
  //
  float InputMoveX = 0;
  bool InputJump = false;
  bool InputVernier = false;
  Transform Transform;
  Rigidbody2D Rigidbody;


  //
  // inherited
  //
  void Awake () {
    Transform = GetComponent<Transform>();

    Rigidbody = GetComponent<Rigidbody2D>();
    Assert.IsNotNull(Rigidbody);


    Assert.IsNotNull(GroundCheckObject);
    GroundCheckScript = GroundCheckObject.GetComponent<GroundCheck>();

    Assert.IsNotNull(GroundCheckScript);
  }


  void FixedUpdate()
  {
    InputMoveX = Input.GetAxisRaw("Horizontal");
    InputJump = Input.GetButtonDown("Jump");
    InputVernier = Input.GetButtonDown("Fire3");

    bool isGrounded = GroundCheckScript.IsGrounded();

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
  }
}
