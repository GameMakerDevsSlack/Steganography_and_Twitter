///surface_to_buffer( surface )

var buffer = buffer_create( surface_get_width( argument0 ) * surface_get_height( argument0 ) * 4, buffer_fixed, 1 );
buffer_get_surface( buffer, argument0, 0, 0, 0 );
return buffer;
