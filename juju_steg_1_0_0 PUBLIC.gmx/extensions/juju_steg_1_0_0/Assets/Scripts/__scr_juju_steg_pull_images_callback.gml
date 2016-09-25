///__scr_juju_steg_pull_images_callback( backgrounds list )
//  
//  Internal script. Do not modify.
//  
//  
//      
//  Copyright (c) 2016 Julian T. Adams / @jujuadams
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the //  Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the //  Software,
//  and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in allcopies or substantial portions of the
//  Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
//  THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A //  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

var list = argument0;
if ( !script_exists( steg_callback ) ) exit;

var output = ds_list_create();

//Set our blend mode to "overwrite"
draw_set_blend_mode_ext( bm_one, bm_zero );

//Go through each background that's been downloaded
var size = ds_list_size( list );
for( var i = 0; i < size; i++ ) {
    
    var background = ds_list_find_value( list, i );
    
    //Create a surface for this background and copy it across
    var surface = surface_create( background_get_width( background ), background_get_height( background ) );
    surface_set_target( surface );
    draw_background( background, 0, 0 );
    surface_reset_target();
    
    //Attempt to decode data hidden in the image
    var buffer = scr_juju_steg_get( surface );
    
    //If we've been successful, add the new buffer to our ouput list
    if ( buffer != noone ) ds_list_add( output, buffer );
    surface_free( surface );
    
}

draw_set_blend_mode( bm_normal );
ds_list_destroy( list );

//Scan for duplicate buffers and remove them from the list
//Create a temporary map to store buffer hashes
var map = ds_map_create();

var size = ds_list_size( output );
for( var i = size-1; i >= 0; i-- ) {
    
    var buffer = ds_list_find_value( output, i );
    
    //Take a SHA1 hash of the buffer data
    var sha1 = buffer_sha1( buffer, 0, buffer_get_size( buffer ) );
    
    //If the hash isn't already in our temporary map, add it...
    if ( is_undefined( ds_map_find_value( map, sha1 ) ) ) {
        
        ds_map_add( map, sha1, i );
    
    //...otherwise remove the buffer from the output list and delete/destroy the buffer
    } else {
        
        ds_list_delete( output, i );
        buffer_delete( buffer );
        
    }
    
}

//Clean up
ds_map_destroy( map );

//Execute the appropriate callback script
script_execute( steg_callback, output );
