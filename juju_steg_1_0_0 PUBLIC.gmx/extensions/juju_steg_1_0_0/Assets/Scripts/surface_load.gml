///surface_load( filename, [surface] )
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


var background = background_add( argument[0], false, false );

if ( argument_count > 1 ) {
    var surface = argument[1];
} else {
    var surface = surface_create( background_get_width( background ), background_get_height( background ) );
}

draw_set_blend_mode_ext( bm_one, bm_zero );
surface_set_target( surface );
draw_background( background, 0, 0 );
surface_reset_target();
draw_set_blend_mode( bm_normal );

background_delete( background );

return surface;
