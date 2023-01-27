/// @ignore
/// feather ignore all
function __scrrible_gpu_state_singleton() {
	static _inst = {
		gpu_blend_enable: undefined,
		gpu_blend_mode: undefined,
		gpu_colour_write: undefined,
		gpu_alpha_test: undefined,
		gpu_tex_filter: undefined,
		gpu_fog: undefined,
		gpu_lighting: undefined,
		gpu_zwrite: undefined,
		gpu_ztest: undefined,
		gpu_cullmode: undefined,
		gpu_zfunc: undefined,
		gpu_flitering: undefined,
		gpu_mip_enabled: undefined,
		matrix_world: undefined,
		matrix_view: undefined,
		matrix_proj: undefined,
		shader: -1,
		is_sterilized: false,
	}
	
	return _inst;
}