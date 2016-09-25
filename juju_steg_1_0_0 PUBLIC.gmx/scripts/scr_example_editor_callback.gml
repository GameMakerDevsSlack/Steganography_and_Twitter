///scr_example_editor_callback( buffer list )

with( obj_editor ) {
    
    var list = argument0;
    if ( ds_list_size( list ) <= 0 ) exit;
    
    //Iterate over the list of our current grids and delete/destroy all of them
    var size = ds_list_size( lst_grids );
    for( var i = size-1; i >= 0; i-- ) {
        var grd = ds_list_find_value( lst_grids, i );
        ds_list_delete( lst_grids, i );
        ds_grid_destroy( grd );
    }
    
    //Iterate over the list of buffers extracted from images
    var size = ds_list_size( list );
    for( var i = size-1; i >= 0; i-- ) {
        
        var buffer = ds_list_find_value( list, i );
        
        //Create a new grid for this data
        var grd = ds_grid_create( grid_w, grid_h );
        ds_list_add( lst_grids, grd );
        
        //Transfer the buffer data into the grid
        buffer_seek( buffer, buffer_seek_start, 0 );
        for( var yy = 0; yy < grid_h; yy++ ) {
            for( var xx = 0; xx < grid_w; xx++ ) {
                ds_grid_set( grd, xx, yy, buffer_read( buffer, buffer_f32 ) );
            }
        }
        
        buffer_delete( buffer );
        
    }
    
    //Set our grid viewer to the first image downloaded (which is chronologically the first/oldest tweet)
    grid_page = 0;
    grid = ds_list_find_value( lst_grids, grid_page );
    
}
