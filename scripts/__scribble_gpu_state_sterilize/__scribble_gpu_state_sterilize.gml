/// @ignore
/// feather ignore all
function __scribble_gpu_state_sterilize(){
    gml_pragma("forceinline");
	static _inst = __scrrible_gpu_state_singleton()
	_instance.is_sterilized = true;
	// Get GPU state
	_inst.gpu_blend_enable =		gpu_get_blendenable();
	_inst.gpu_blend_mode =		    gpu_get_blendmode_ext_sepalpha();
	_inst.gpu_colour_write =		gpu_get_colourwriteenable();
	_inst.gpu_alpha_test =			gpu_get_alphatestenable();
	_inst.gpu_tex_filter =			gpu_get_texfilter();
	_inst.gpu_fog =					gpu_get_fog();
	_inst.gpu_lighting =			draw_get_lighting();
	_inst.gpu_colour =				draw_get_color();
	_inst.gpu_alpha =				draw_get_alpha();
	_inst.gpu_zwrite =				gpu_get_zwriteenable();
	_inst.gpu_ztest =				gpu_get_ztestenable();
	_inst.gpu_cullmode =			gpu_get_cullmode();
	_inst.gpu_zfunc =				gpu_get_zfunc();
	_inst.gpu_filtering =			gpu_get_tex_filter();
	_inst.gpu_mip_enabled =		    gpu_get_tex_mip_enable();
	_inst.matrix_world =			matrix_get(matrix_world);
	_inst.matrix_view =				matrix_get(matrix_view);
	_inst.matrix_proj =				matrix_get(matrix_projection);
	_inst.shader =					shader_current();
	
	// Change GPU settings
	static _matrix_default = matrix_build_identity();
	gpu_set_blendenable(false);
	gpu_set_blendmode(bm_normal);
	gpu_set_colourwriteenable(true, true, true, true);
	gpu_set_alphatestenable(false);
	gpu_set_texfilter(false);
	gpu_set_fog(false, c_black, 0, 1);
	draw_set_colour(c_white);
	draw_set_alpha(1);
	gpu_set_zwriteenable(false);
	gpu_set_ztestenable(false);
	gpu_set_cullmode(cull_noculling);
	gpu_set_zfunc(cmpfunc_lessequal);
	gpu_set_tex_filter(false);
	gpu_set_tex_mip_enable(false);
	matrix_set(matrix_world, _matrix_default);
	matrix_set(matrix_view, _matrix_default);
	matrix_set(matrix_projection, _matrix_default);
	shader_reset();
}