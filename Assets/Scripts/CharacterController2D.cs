using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement; // include so we can load new scenes

public class CharacterController2D : MonoBehaviour {

  [Range(0.0f, 10.0f)]
  public float MoveSpeed = 3f;

  [Range(0.0f, 20.0f)]
  public float JumpSpeed = 6f;

  public LayerMask WhatIsGround;

  // Transform just below feet for checking if player is grounded
  public Transform GroundCheck;


  // private stuff
  float InputMoveX = 0;
  bool InputJump = false;
  bool InputRun = false;
  Transform Transform;
  Rigidbody2D Rigidbody;
  int PlatformCollisionLayer;
  bool IsGrounded = false;


  void Awake () {
    // get a reference to the components we are going to be changing and store a reference for efficiency purposes
    Transform = GetComponent<Transform>();

    Rigidbody = GetComponent<Rigidbody2D>();
    if (Rigidbody == null) throw new System.ArgumentNullException("No Rigidbody2D");

    // determine the platform's specified layer
    PlatformCollisionLayer = LayerMask.NameToLayer("Platform");
    //Debug.Log(PlatformCollisionLayer);
  }


  // this is where most of the player controller magic happens each game event loop
  void Update()
  {
    InputMoveX = Input.GetAxisRaw("Horizontal");
    InputJump = Input.GetButtonDown("Jump");
    InputRun = Input.GetButtonDown("Fire3");


    // Check to see if character is grounded by raycasting from the middle of the player
    // down to the GroundCheck position and see if collected with gameobjects on the
    // WhatIsGround layer
    IsGrounded = Physics2D.Linecast(Transform.position, GroundCheck.position, WhatIsGround);


    // Jump
    float vy = Rigidbody.velocity.y;
    if (IsGrounded && InputJump) {
      vy = Mathf.Max(vy, JumpSpeed);
    }

    // update rigidbody
    Rigidbody.velocity = new Vector2(InputMoveX * MoveSpeed, vy);


    // If the player stops jumping mid jump and player is not yet falling
    // then set the vertical velocity to 0 (he will start to fall from gravity)
    //if(Input.GetButtonUp("Jump") && Vy>0f)
    //{
      //Vy = 0f;
    //}


    // if moving up then don't collide with platform layer
    // this allows the player to jump up through things on the platform layer
    // NOTE: requires the platforms to be on a layer named "Platform"
    //
    // TODO Physics2D.IgnoreLayerCollision(this.gameObject.layer, PlatformCollisionLayer, (vy > 0.0f));
  }
}
