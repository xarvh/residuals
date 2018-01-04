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
  public float MaxJumpForceMagnitude = 300f;

  [Range(0f, 5f)]
  public float ExtraJumpOverBaseJumpRatio = 0.5f;

  // When a mecha passes through a one-way platform is still considered "grounded" and can jump.
  // This is why one-way platforms should be thin.
  // Still, if the player holds the jump button down AddForce will be called for every tick that the mecha is inside
  // the platform, allowing ridiculaously high jumps.
  //
  // To work around this problem, we allow the mecha to jump only if its velocity in a particular direction is below this value.
  //
  // TODO: split between horizontal limit and vertical limit?
  public float MaxSpeedForJumping = 0.5f;


  //
  public GameObject GroundCheckObject;
  GroundCheck GroundCheckScript;

  //
  // private
  //
  float InputMoveX = 0;
  float InputMoveY = 0;
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


  void Update() {
    InputMoveX = Input.GetAxisRaw("Horizontal");
    InputMoveY = Input.GetAxisRaw("Vertical");
    InputJump = Input.GetButton("Jump");
    InputVernier = Input.GetButton("Fire3");
  }


  void FixedUpdate() {
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

      float walkForce = WalkMaximumSpeed * 4.0f;

      Rigidbody.AddForce(Transform.right * walkForce * limiter);
    }

    // Jump
    if (isGrounded && InputJump) {
      if (InputMoveY < 0) {
        // TODO Jump down platform
      } else {
        //
        // B: base force
        // E: extra force
        // R: ratio
        //
        // B + E = max force
        // E / B = R
        //

        // B = max / (1 + R)
        float baseMagnitude = MaxJumpForceMagnitude / (1 + ExtraJumpOverBaseJumpRatio);

        float extraMagnitude = baseMagnitude * ExtraJumpOverBaseJumpRatio;

        Vector3 extraDirection = Vector3.ClampMagnitude(new Vector3(InputMoveX, InputMoveY, 0), 1);

        Vector3 force = baseMagnitude * Transform.up + extraMagnitude * extraDirection;

        if (force.y > 0 && vy > MaxSpeedForJumping) {
          force.y = 0;
        }

        if (force.x > 0 && vx > MaxSpeedForJumping) {
          force.x = 0;
        }

        if (force.x < 0 && vx < -MaxSpeedForJumping) {
          force.x = 0;
        }

        Rigidbody.AddForce(force);
      }
    }
  }
}
