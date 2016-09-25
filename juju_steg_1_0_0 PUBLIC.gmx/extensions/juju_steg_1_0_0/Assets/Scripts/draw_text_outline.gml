///draw_text_outline( x, y, string, outline colour )

var xx     = argument0;
var yy     = argument1;
var str    = argument2;
var colour = argument3;

var old_colour = draw_get_colour();

draw_set_colour( colour );
draw_text( xx - 1, yy, str );
draw_text( xx + 1, yy, str );
draw_text( xx, yy - 1, str );
draw_text( xx, yy + 1, str );
draw_set_colour( old_colour );
draw_text( xx, yy, str );
