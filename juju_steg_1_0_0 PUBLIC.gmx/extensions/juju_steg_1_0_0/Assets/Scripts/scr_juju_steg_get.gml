///scr_juju_steg_get( surface )
//  
//  Reverses the operation desecribed in scr_juju_steg_get().
//  
//  This function returns a buffer index ( >= 0 ) if successful and noone (-4) if the process failed.
//  If unsuccessful, the failure mode is written to the compile form.
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

//Obtain the raw image data
var image_buffer = surface_to_buffer( surface );

//Set up a buffer to catch the data size
var header_buffer = buffer_create( 45, buffer_fixed, 1 );

//Build a u32 value from the first four bytes (the first 32 pixels)
var i, j, character;
for( i = 0; i < 45; i++ ) {
    character = 0;
    for( j = 0; j < 8; j++ ) {
        character += ( buffer_peek( image_buffer, 8*i + j, buffer_u8 ) & 1 ) << j;
    }
    buffer_poke( header_buffer, i, buffer_u8, character );
}

//Extract the size from the buffer
buffer_seek( header_buffer, buffer_seek_start, 0 );
var size = buffer_read( header_buffer, buffer_u32 );
var sha1 = buffer_read( header_buffer, buffer_string );
buffer_delete( header_buffer );

if ( size > scr_juju_steg_max_size( surface ) ) {
    show_debug_message( "scr_juju_steg_broad_get: Error! Stated size is impossible" );
    return noone;
}

//Create an output buffer of the requisite size
var data_buffer = buffer_create( size, buffer_fixed, 1 );

//Build the data
for( i = 45; i < size + 45; i++ ) {
    character = 0;
    for( j = 0; j < 8; j++ ) character += ( buffer_peek( image_buffer, 8*i + j, buffer_u8 ) & 1 ) << j;
    buffer_poke( data_buffer, i - 45, buffer_u8, character );
}

//Clean up
buffer_delete( image_buffer );

if ( sha1 != buffer_sha1( data_buffer, 0, size ) ) {
    show_debug_message( "scr_juju_steg_broad_get: Error! SHA1 failure" );
    buffer_delete( data_buffer );
    return noone;
}

//Return the new buffer
return data_buffer;
