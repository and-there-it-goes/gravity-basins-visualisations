extends TextureRect

const movie_mode: bool = false

var grabbed_node: CanvasItem = null

var simulation_visible: float = 1.0
var simulation_visible_delta: float = 1.0

var visualisation: int = 0

func _ready() -> void:
	if movie_mode:
		material.set_shader_parameter(&"steps", 20000)
		play_movie()
	update_bodies()
	for child in get_children():
		if child.is_in_group(&"draggable"):
			child.hide()

func update_bodies() -> void:
	material.set_shader_parameter(&"body1", get_child(0).global_position)
	material.set_shader_parameter(&"body2", get_child(1).global_position)
	material.set_shader_parameter(&"body3", get_child(2).global_position)
	$Particles.process_material.set_shader_parameter(&"body1", get_child(0).global_position)
	$Particles.process_material.set_shader_parameter(&"body2", get_child(1).global_position)
	$Particles.process_material.set_shader_parameter(&"body3", get_child(2).global_position)

func _process(delta: float) -> void:
	if movie_mode:
		pass
	else:
		if Input.is_action_just_pressed(&"drag"):
			var nearest_distance := INF
			for child in get_children():
				if child.is_in_group(&"draggable"):
					var child_distance = child.global_position.distance_to(get_global_mouse_position())
					if child_distance <= nearest_distance:
						grabbed_node = child
						nearest_distance = child_distance
			if nearest_distance >= 24.0: grabbed_node = null
		elif Input.is_action_just_released(&"drag"):
			grabbed_node = null
		
		if Input.is_action_just_pressed(&"toggle_sim"): simulation_visible_delta *= -1.0
		simulation_visible = clampf(simulation_visible + simulation_visible_delta * delta * 2.0, 0.0, 1.0)
		material.set_shader_parameter(&"visibility_factor", smoothstep(0.0, 1.0, simulation_visible))
		
		if Input.is_action_just_pressed(&"next_visualisation"):
			const v_order: Array[int] = [0, 3, 1, 6, 7, 8, 10, 9, 11, 2, 4, 5]
			visualisation += 1
			visualisation %= v_order.size()
			var v = v_order[visualisation]
			print("visualisation ", v)
			material.set_shader_parameter(&"visualisation_type0", v)
			material.set_shader_parameter(&"visualisation_mix", 0.0)
		
		if grabbed_node and Input.is_action_pressed(&"drag"):
			grabbed_node.global_position = get_global_mouse_position().clamp(Vector2.ZERO, size)
			update_bodies()
			mouse_default_cursor_shape = Control.CURSOR_DRAG
		else:
			mouse_default_cursor_shape = Control.CURSOR_CROSS
			
			if Input.is_action_just_pressed(&"emit"):
				var p := get_global_mouse_position().clamp(Vector2.ZERO, size)
				$Particles.process_material.set_shader_parameter(&"start_pos", p)
				$Particles.emit_particle(Transform2D.IDENTITY, Vector2.ZERO, Color.WHITE, Color(0.0, 0.0, 0.0, 0.0), 0)



class GravityTextureAnimator extends Node:
	
	var body1 := Vector2(557.0, 139.0)
	var body2 := Vector2(271.0, 414.0)
	var body3 := Vector2(848.0, 460.0)
	var visualisation0: int = 0
	var visualisation1: int = 1
	var visualisation_blend: float = 0.0
	var init_velocity := Vector2.ZERO
	var opacity: float = 1.0
	
	var mat: ShaderMaterial
	
	var plan_time_cursor: float = 0.0
	var play_time: float = 0.0
	
	func delay(time: float) -> void:
		plan_time_cursor += time
	
	func blend_to_visualisation(id: int, time: float, ease_type: Tween.EaseType, trans_type: Tween.TransitionType) -> float:
		var t := Timer.new()
		add_child(t)
		t.one_shot = true
		t.start(plan_time_cursor)
		t.timeout.connect(
			func():
				visualisation0 = visualisation1
				visualisation_blend = 0.0
				visualisation1 = id
				var tw := create_tween().set_ease(ease_type).set_trans(trans_type)
				tw.tween_property(self, ^"visualisation_blend", 1.0, time).from(0.0)
				tw.chain().tween_callback(
					func():
						visualisation0 = visualisation1
						visualisation_blend = 0.0
				)
		)
		return time
	
	func tween_prop(property: NodePath, final_val: Variant, duration: float, ease_type: Tween.EaseType, trans_type: Tween.TransitionType, from: Variant = null) -> float:
		var t := Timer.new()
		add_child(t)
		t.one_shot = true
		t.start(plan_time_cursor)
		t.timeout.connect(
			func():
				var tw := create_tween().set_ease(ease_type).set_trans(trans_type)
				var pt := tw.tween_property(self, property, final_val, duration)
				if from != null: pt.from(from)
		)
		return duration
	
	func _init(target_material: ShaderMaterial) -> void:
		mat = target_material
	
	func _process(delta: float) -> void:
		mat.set_shader_parameter(&"body1", body1)
		mat.set_shader_parameter(&"body2", body2)
		mat.set_shader_parameter(&"body3", body3)
		mat.set_shader_parameter(&"init_v", init_velocity)
		mat.set_shader_parameter(&"visualisation_type0", visualisation0)
		mat.set_shader_parameter(&"visualisation_type1", visualisation1)
		mat.set_shader_parameter(&"visualisation_mix", visualisation_blend)
		mat.set_shader_parameter(&"visibility_factor", opacity)
		play_time += delta
		print("Time: ", play_time)
		if play_time > plan_time_cursor:
			print("Movie finished.")
			get_tree().quit()


func play_movie(): #async
	print("Setting up movie...")
	var gta := GravityTextureAnimator.new(material)
	add_child(gta)
	gta.process_mode = Node.PROCESS_MODE_DISABLED
	
	gta.delay(5.0)
	gta.tween_prop(^"body1", Vector2(741, 124), 5.0, Tween.EASE_IN_OUT, Tween.TRANS_EXPO, Vector2(557, 139))
	gta.tween_prop(^"body2", Vector2(317, 176), 5.0, Tween.EASE_IN_OUT, Tween.TRANS_CIRC, Vector2(271, 414))
	gta.tween_prop(^"body3", Vector2(611, 527), 5.0, Tween.EASE_IN_OUT, Tween.TRANS_ELASTIC, Vector2(848, 460))
	gta.delay(10.0)
	gta.blend_to_visualisation(5, 1.0, Tween.EASE_IN_OUT, Tween.TRANS_SINE)
	gta.delay(6.0)
	
	print("Playing movie...")
	gta.process_mode = Node.PROCESS_MODE_PAUSABLE
