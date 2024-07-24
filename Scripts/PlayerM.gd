extends KinematicBody

var speed = 10
var UP = Vector3(0,1,0)

#movement variables
var motion = Vector3()
var facing_direction = 0

#animation constants
const BLEND_MIN = 0.125
const IDLE_BLEND_AMOUNT = 0.05
const RUN_BLEND_AMOUNT = 0.1

#animation variables
var move_state = 0

func _process(delta):
	move()
	facing_forward()
	animate()

func move():
	motion = Vector3(0,0,0)
	
	if Input.is_action_pressed("forward") and not Input.is_action_pressed("back"):
		motion.z = 1
		facing_direction = 0
	if Input.is_action_pressed("back") and not Input.is_action_pressed("forward"):
		motion.z = -1
		facing_direction = PI
	if Input.is_action_pressed("right") and not Input.is_action_pressed("left"):
		motion.x = -1
		facing_direction = PI * 1.5
	if Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
		motion.x = 1
		facing_direction = PI * 0.5
	
	move_and_slide(motion * speed,UP)
	
func facing_forward():
	$Armature.rotation.y = facing_direction
	
func animate():
	var animate = $Armature/AnimationTreePlayer
	
	if motion.length() > BLEND_MIN:
		move_state += RUN_BLEND_AMOUNT
	else:
		move_state -= IDLE_BLEND_AMOUNT
	
	move_state = clamp(move_state,0,1)
	
	animate.blend2_node_set_amount("Move",move_state)
