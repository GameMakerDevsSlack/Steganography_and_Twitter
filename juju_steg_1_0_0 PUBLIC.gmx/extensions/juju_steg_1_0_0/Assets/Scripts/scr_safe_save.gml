///scr_safe_save( prefix, suffix )

var str = argument0;
var suffix = argument1;
do str += string( get_timer() ) until !file_exists( str + suffix );
return str + suffix;
