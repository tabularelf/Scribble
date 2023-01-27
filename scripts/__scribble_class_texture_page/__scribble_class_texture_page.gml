/// @ignore
/// feather ignore all
function __scribble_class_texture_page(_width, _height) {
    static _list = __scribble_get_texture_page_list();
    __width = _width;
    __height = _height;
    __surface = -1;
    __buffer = -1;
    __texture = -1;
    __alive = true;
    ds_list_add(_list, self);
    
    static Start = function() {
        if (!surface_exists(__surface)) {
            if (!buffer_exists(__buffer)) {
                __surfaceCreate();
                surface_set_target(__surface);
                draw_clear_alpha(0, 0);
                surface_reset_target();
            } else {
                Validate();
            }
        }

        surface_set_target(__surface);
    }

    static Finish = function() {
        surface_reset_target();
        if !(buffer_exists(__buffer)) {
            __init();
        }
        
        buffer_get_surface(__buffer, __surface, 0);
    }
    
    static Free = function() {
        if (buffer_exists(__buffer)) {
            buffer_delete(__buffer);
            __buffer = -1;
        }
        
        if (surface_exists(__surface)) {
            surface_free(__surface);	
            __surface = -1;
        }
    }
	
	static Validate = function() {
        if (!__alive) {
            Free();
            return false;
        }
        
        __init();
        if (buffer_exists(__buffer)) {
            if !(surface_exists(__surface)) {
                __surfaceCreate();
                buffer_set_surface(__buffer,__surface,0);
            }
        }
        
        return true;
    }
    
    static __surfaceCreate = function() {
        if (!surface_exists(__surface)) {
            var _depthSetting = surface_get_depth_disable();
            surface_depth_disable(true);
            __surface = surface_create(__width, __height);
            __texture = surface_get_texture(__surface);
            surface_depth_disable(_depthSetting);
        }
    }
    
    static __init = function() {
        if !(buffer_exists(__buffer)) {
            __buffer = buffer_create(__width * __height * 4, buffer_fixed, 4);
        }
    }
}