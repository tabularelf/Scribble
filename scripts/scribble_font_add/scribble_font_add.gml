/// @param {String} name
/// @param {String} filepath
/// @param {Real} size
/// @param {Any} glyphs
/// @param {Boolean} isBold
/// @param {Boolean} isItalics
/// @param {Boolean} isSDF
/// @return {Asset.GMFont}
/// feather ignore all
function scribble_font_add(_name, _filepath, _size, _bold = false, _italics = false, _sdf = false) {
    // Infinity sets first/last to 0... Interesting.
    var _font = font_add(_filepath, _size, _bold, _italics, infinity, infinity);
    
    if (_font == -1) {
        return -1;   
    }
    
    // Variable glyph range is unknown until we parse it at least once, so we fetch it from font_get_info() first.
    __scribble_font_add_parse_from_file(_name, _font, _sdf);
    return _font;
}