///scr_juju_imgur_http_request( title, surface, dev id )
//  
//  Constructs and submits an HTTP request to imgur's upload RESTful API endpoint.
//  http://api.imgur.com/endpoints/image
//  
//  This script saves a surface to local storage as a .png for three reasons:
//      - Lower filesize means network transfer will be faster
//      - Small transfers are typically more reliable
//  
//  Image files are limited to 10mb. An compressed bitmap that's a 4K image, either UHD-1 3840 x 2160 or
//  DCI 4096 x 2160, is well under the limit. A filesize cap of 10mb is very generous!
//  
//  In order to use the imgur API, a unique developer indentifier is needed. Please visit imgur.com and follow their
//  developer instructions to receive a dev id.
//  
//  This script follows the RFC1341 multipart defintion:
//  https://www.w3.org/Protocols/rfc1341/7_2_Multipart.html
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

//Create a couple of handy variables to improve readability
var newline = chr( 13 ) + chr( 10 );
var boundary = "----" + sha1_string_unicode( string( date_current_datetime() ) );

var title   = argument0;
var surface = argument1;
var auth    = argument2;

//Save the surface to a random file location, compressing it into a .png in the process
var filename = scr_safe_save( "", ".png" );
surface_save( surface, filename );

//Load the .png back in as a pure buffer
var file_buffer = buffer_load( filename );

//Create a buffer for the body of the HTTP request
var predicted_length = 259 + string_length( title ) + string_length( filename ) + buffer_get_size( file_buffer ); //May not always be accurate
var body = buffer_create( predicted_length, buffer_grow, 1 );

//Write the image title into the body
buffer_write( body, buffer_text, '--' + boundary + newline + 'Content-Disposition: form-data; name="title"' + newline + newline + title + newline );

//Write the filename into the body
buffer_write( body, buffer_text, '--' + boundary + newline + 'Content-Disposition: form-data; name="image"; filename="' + filename+ '"' + newline + newline );

//Copy across the .png data
buffer_copy( file_buffer, 0, buffer_get_size( file_buffer ), body, buffer_tell( body ) );
buffer_seek( body, buffer_seek_relative, buffer_get_size( file_buffer ) );
buffer_write( body, buffer_text, newline );

//Terminate the multipart request
buffer_write( body, buffer_text, '--' + boundary + '--' + newline );

//Create the header
var map = ds_map_create();
ds_map_add( map, "Authorization" , "Client-ID " + auth );
ds_map_add( map, "Content-Type"  , "multipart/form-data; boundary=" + boundary );
ds_map_add( map, "User-Agent"    , "GenericHTTP" );
ds_map_add( map, "Content-Length", string( buffer_tell( body ) ) );

//Send off the request
var ID = http_request( "https://api.imgur.com/3/image.json", "POST", map, body );

//Clean up to prevent memory leaks
file_delete( filename );
buffer_delete( file_buffer );
buffer_delete( body );
ds_map_destroy( map );

return ID;
