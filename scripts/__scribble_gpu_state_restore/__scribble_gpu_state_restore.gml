/// @ignore
/// feather ignore all
function __scribble_gpu_state_restore() {
	gml_pragma("forceinline");
	static _inst = __scrrible_gpu_state_singleton();
	_inst.is_sterilized = false;
    
	// Restore settings
	gpu_set_blendenable(_inst.gpu_blend_enable);
	gpu_set_blendmode_ext_sepalpha(_inst.gpu_blend_mode);
	gpu_set_colourwriteenable(_inst.gpu_colour_write);
	gpu_set_alphatestenable(_inst.gpu_alpha_test);
	gpu_set_texfilter(_inst.gpu_tex_filter);
    // This was previously used to address a specific bug in HTML5... It's already fixed by GM2022.11 (or was it GM2023.1, I can't recall)
	//var _gpuFog = _inst.gpu_fog;
	gpu_set_fog(_inst.gpu_fog);
	draw_set_lighting(_inst.gpu_lighting);
	draw_set_colour(_inst.gpu_colour);
	draw_set_alpha(_inst.gpu_alpha);
	gpu_set_zwriteenable(_inst.gpu_zwrite);
	gpu_set_ztestenable(_inst.gpu_ztest);
	gpu_set_cullmode(_inst.gpu_cullmode);
	gpu_set_zfunc(_inst.gpu_zfunc);
	gpu_set_tex_filter(_inst.gpu_filtering);
	gpu_set_tex_mip_enable(_inst.gpu_mip_enabled);
	matrix_set(matrix_world, _inst.matrix_world);
	matrix_set(matrix_view, _inst.matrix_view);
	matrix_set(matrix_projection, _inst.matrix_proj);
	if (_inst.shader != -1) {
		shader_set(_inst.shader);	
	}
}