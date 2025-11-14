extends GPUParticles2D

const copy_params: Array[StringName] = [
	&"body1",
	&"body2",
	&"body3",
	&"init_v",
	&"epsilon",
	&"rmul",
	&"d",
]

func _process(delta: float) -> void:
	
	var parent_material: ShaderMaterial = get_parent().material
	
	for p in copy_params:
		process_material.set_shader_parameter(p, parent_material.get_shader_parameter(p))
	
	var t: float = parent_material.get_shader_parameter(&"t")
	process_material.set_shader_parameter(&"t", t)
	process_material.set_shader_parameter(&"tSquared", t*t)
