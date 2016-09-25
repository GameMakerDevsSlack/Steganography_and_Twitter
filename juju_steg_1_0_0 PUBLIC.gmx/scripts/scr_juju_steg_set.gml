///scr_juju_steg_set( surface, data buffer )
//  
//  Uses steganography to hide data in the least significant bit of each channel (RGBA) of each pixel on a surface.
//  Despite reducing the possible colour space, this is virtually unnoticeable to the human eye. Lossy compression
//  (e.g. jpg) will corrupt the data hidden in the image file. It is important files are kept in lossless
//  formats (e.g. png) if the data is to be preserved.
//  
//  This function does NOT return a new surface, it modifies the input surface.
//  
//  The first 45 bytes of data is a header containing:
//      - 4 bytes containing the size of the data (not including the header)
//      - 40 bytes containing a SHA-1 checksum (in hex), used to verify integrity upon decoding.
//      - A null character
//  
//  The maximum data that can be stored using this method is given by (in bytes):
//        ( width * height / 2 ) - 45
//  This number can be calculated using scr_juju_steg_max_size().
//  
//  This function returns true (1) if the surface has been successfully modified or false (0) if the operation failed.
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

var surface = argument0;
var data_buffer = argument1;

//Work out if there's enough space 
var size = buffer_get_size( data_buffer );
if ( size > scr_juju_steg_max_size( surface ) ) {
    show_debug_message( "scr_juju_steg_broad_set: Error! Data exceeds maximum for this image size" );
    return false;
}

//Obtain the raw image data from the surface
var image_buffer = surface_to_buffer( surface );

//Imprint the size of the data buffer
var header_buffer = buffer_create( 45, buffer_fixed, 1 );
buffer_write( header_buffer, buffer_u32, size );
buffer_write( header_buffer, buffer_string, buffer_sha1( data_buffer, 0, size ) );

for( var i = 0; i < 45; i++ ) {
    var character = buffer_peek( header_buffer, i, buffer_u8 );
    for( var j = 0; j < 8; j++ ) {
        var pos = 8*i + j;
        //show_message( string( pos ) + " : " + string( character & 1 ) );
        buffer_poke( image_buffer, pos, buffer_u8, ( buffer_peek( image_buffer, pos, buffer_u8 ) & $FE ) + ( character & 1 ) );
        var character = character >> 1;
    }
}

//Imprint the data itself
for( var i = 45; i < size + 45; i++ ) {
    var character = buffer_peek( data_buffer, i - 45, buffer_u8 );
    for( var j = 0; j < 8; j++ ) {
        var pos = 8*i + j;
        buffer_poke( image_buffer, pos, buffer_u8, ( buffer_peek( image_buffer, pos, buffer_u8 ) & $FE ) + ( character & 1 ) );
        var character = character >> 1;
    }
}

//Transfer the image buffer back to the surface
buffer_set_surface( image_buffer, surface, 0, 0, 0 );

//Clean up
buffer_delete( image_buffer );
buffer_delete( header_buffer );

return true;
