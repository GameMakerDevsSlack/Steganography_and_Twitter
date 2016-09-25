///scr_example_post_image_error( error code )
//  
//  Simple error reporting script for scr_juju_twitter_post_image()

var code = argument0;

switch( code ) {
    
    case enum_juju_twitter_post_image_error.timeout:
        show_debug_message( "scr_example_post_image_error: Timeout" );
    break;
    
    case enum_juju_twitter_post_image_error.destroyed:
        show_debug_message( "scr_example_post_image_error: Instance destroyed" );
    break;
    
    case enum_juju_twitter_post_image_error.http:
        show_debug_message( "scr_example_post_image_error: HTTP request failed" );
    break;
    
    case enum_juju_twitter_post_image_error.busy:
        show_debug_message( "scr_example_post_image_error: Upload already in progress" );
    break;
    
    case enum_juju_twitter_post_image_error.imgur:
        show_debug_message( "scr_example_post_image_error: imgur returned an error" );
    break;
    
    
}
