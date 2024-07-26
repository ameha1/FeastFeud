extends KinematicBody

var speed = 10
var UP = Vector3(0,1,0)

#movement variables
var vel = Vector3()
var dir = Vector3()
var facing_direction = 0

#movement constants
const MAX_SPEED = 20
const ACCEL = 5
const DECCEL = 15
const JUMP_SPEED = 15
const GRAVITY = -45

#animation constants
const BLEND_MIN = 0.125
const IDLE_BLEND_AMOUNT = 0.5
const RUN_BLEND_AMOUNT = 0.1

#animation variables
var move_state = 0

func _process(delta):
	move(delta)
	facing_forward()
	animate()

func move(delta):
	var movement_dir = get_2D_movement()
	var camera_xform = $Camera.get_global_transform()
	
	dir = Vector3(0,0,0)
	
	dir += camera_xform.basis.z.normalized() * movement_dir.y
	dir += camera_xform.basis.x.normalized() * movement_dir.x
	
	dir = move_vertically(dir, delta)
	vel = h_accel(dir, delta)
	
	
	move_and_slide(vel, UP)


func get_2D_movement():
	var movemnt_vector = Vector2()
	
	if Input.is_action_pressed("forward") and not Input.is_action_pressed("back"):
		movemnt_vector.y = -1
		facing_direction = 0
	if Input.is_action_pressed("back") and not Input.is_action_pressed("forward"):
		movemnt_vector.y = 1
		facing_direction = PI
	if Input.is_action_pressed("right") and not Input.is_action_pressed("left"):
		movemnt_vector.x = 1
		facing_direction = PI * 1.5
	if Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
		movemnt_vector.x = -1
		facing_direction = PI * 0.5
		
	return movemnt_vector.normalized()


func move_vertically(dir, delta):
	vel.y += GRAVITY*delta
	
	if Input.is_action_pressed("jump") and is_on_floor():
		vel.y = JUMP_SPEED
	elif is_on_floor():
		vel.y = 0
		
	dir.y = 0
	dir = dir.normalized()
	
	return dir


func h_accel(dir, delta):
	var vel_2D = vel
	vel_2D.y = 0
	
	var target = dir
	target *= MAX_SPEED
	
	var accel
	
	if dir.dot(vel_2D) > 0:
		accel = ACCEL
	else:
		accel = DECCEL
		
	vel_2D = vel_2D.linear_interpolate(target, accel*delta)
	
	vel.x = vel_2D.x
	vel.z = vel_2D.z
	
	return vel


func facing_forward():
	$Armature.rotation.y = facing_direction
	
func animate():
	var animate = $Armature/AnimationTreePlayer
	
	if vel.length() > BLEND_MIN:
		move_state += RUN_BLEND_AMOUNT
	else:
		move_state -= IDLE_BLEND_AMOUNT
	
	move_state = clamp(move_state,0,1)
	
	animate.blend2_node_set_amount("Move",move_state)
