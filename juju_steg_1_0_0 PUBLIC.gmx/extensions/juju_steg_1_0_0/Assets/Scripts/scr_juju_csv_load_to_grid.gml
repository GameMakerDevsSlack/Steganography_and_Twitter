///scr_juju_csv_load_to_grid( file, [cell delimiter], [text delimiter] )
//  
//  Loads a .csv file into a ds_grid that is automatically sized to the data.
//  Useful for translations, dialogue trees, mods etc.
//  
//  
//  
//  Copyright (c) 2015 Julian T. Adams / @jujuadams
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


//Collect the filename. You don't strictly have to do this but it's good practice for larger scripts in case you need to change things around
switch( argument_count ) {
    
    case 1:
        var file = argument[0];
        var cellDelimiter = "";
        var textDelimiter = "";
    break;
    
    case 2:
        var file = argument[0];
        var cellDelimiter = argument[1];
        var textDelimiter = "";
    break;
    
    case 3:
        var file = argument[0];
        var cellDelimiter = argument[1];
        var textDelimiter = argument[2];
    break;
    
    default:
        show_debug_message( "scr_juju_csv_load_to_grid: Error! Unsupported number of arguments" );
        return noone;
    break;
    
}

if ( cellDelimiter == "" ) cellDelimiter = ",";
if ( textDelimiter == "" ) textDelimiter = chr(34);


var cellDelimiterOrd = ord( cellDelimiter );
var textDelimiterOrd = ord( textDelimiter );

buffer = buffer_load( file );

//Initialise width and height of the spreadsheet
var sheetWidth = 0;
var sheetHeight = 1;

var prevVal = 0;
var nextVal = 0;
var val = 0;
var str = "";
var inText = false;
var grid = noone;

var size = buffer_get_size( buffer );
for( var i = 0; i < size; i++ ) {
    
    prevVal = val;
    var val = buffer_read( buffer, buffer_u8 );
    
    if ( val == 13 ) continue;
    
    if ( val == textDelimiterOrd ) {
        
        var nextVal = buffer_peek( buffer, buffer_tell( buffer ), buffer_u8 );
        
        if ( inText ) {
            if ( nextVal == textDelimiterOrd ) continue;
            if ( prevVal == textDelimiterOrd ) {
                str += textDelimiter;
                continue;
            }
        }
        
        inText = !inText;
        continue;
        
    }
    
    if ( inText ) and ( ( prevVal == 13 ) and ( val == 10 ) ) {   
        str += "#";
        continue;
    }
    
    if ( ( val == cellDelimiterOrd ) or ( ( prevVal == 13 ) and ( val == 10 ) ) ) and ( !inText ) {
        
        sheetWidth++;
        if ( grid == noone ) {
            grid = ds_grid_create( max( 1, sheetWidth ), max( 1, sheetHeight ) );
            ds_grid_clear( grid, "" );
        } else ds_grid_resize( grid, max( sheetWidth, ds_grid_width( grid ) ), sheetHeight );
        
        ds_grid_set( grid, sheetWidth - 1, sheetHeight - 1, str );
        str = "";
        inText = false;
        
        if ( val == 10 ) {
            sheetWidth = 0;
            sheetHeight++;
        }
        
        continue;
    }
    
    str += chr( val );
    
}

buffer_delete( buffer );

sheetWidth = ds_grid_width( grid );
sheetHeight = ds_grid_height( grid );
for( var yy = 0; yy < sheetHeight; yy++ ) {
    for( var xx = 0; xx < sheetWidth; xx++ ) {
        var val = ds_grid_get( grid, xx, yy );
        if ( !is_string( val ) ) ds_grid_set( grid, xx, yy, "" );
    }
}

//Return the grid, ready for use elsewhere
return grid;
