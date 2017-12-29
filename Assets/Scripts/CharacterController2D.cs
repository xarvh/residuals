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

  // When a mecha passes through a one-way platform is still considered "grounded" and can jump.
  // This is why one-way platforms should be thin.
  // Still, if the player holds the jump button down AddForce will be called for every tick that the mecha is inside
  // the platform, allowing ridiculaously high jumps.
  //
  // To work around this problem, we allow the mecha to jump only if its vertical velocity is below this value.
  float maximumVerticalSpeedForJumping = 1;

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
    InputJump = Input.GetButton("Jump");
    InputVernier = Input.GetButton("Fire3");

    bool isGrounded = GroundCheckScript.IsGrounded();
    bool isGroundedOnPlatform = GroundCheckScript.IsGroundedOnPlatform();

    float vx = Rigidbody.velocity.x;
    float vy = Rigidbody.velocity.y;

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
    if (isGrounded && InputJump && vy < maximumVerticalSpeedForJumping) {
      Rigidbody.AddForce(Transform.up * JumpForce);
    }
  }
}
