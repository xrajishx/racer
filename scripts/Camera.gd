extends Camera

var distance = 3.5
var height = 1.5

export (NodePath) var target = null
var target_node

func _ready():
	target_node = get_node(target)

func _physics_process(_delta):
	var target_position = target_node.global_transform.origin
	
	var offset = global_transform.origin - target_position
	offset = offset.normalized() * distance
	offset.y = height
	
	var new_position = target_position + offset
	target_position.y = target_position.y + 2
	
	look_at_from_position(new_position, target_position, Vector3(0, 1, 0))