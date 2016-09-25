///scr_example_pull_images_error( error code )
//  
//  Simple error reporting script for scr_juju_twitter_pull_images()

var code = argument0;

switch( code ) {
    
    case enum_juju_twitter_pull_images_error.timeout:
        show_debug_message( "scr_example_pull_images_error: Timeout" );
    break;
    
    case enum_juju_twitter_pull_images_error.token:
        show_debug_message( "scr_example_pull_images_error: Token malformed. Check developer ID" );
    break;
    
    case enum_juju_twitter_pull_images_error.no_tweets:
        show_debug_message( "scr_example_pull_images_error: No tweets found" );
    break;
    
    case enum_juju_twitter_pull_images_error.no_images:
        show_debug_message( "scr_example_pull_images_error: No images found" );
    break;
    
    case enum_juju_twitter_pull_images_error.destroyed:
        show_debug_message( "scr_example_pull_images_error: Instance destroyed" );
    break;
    
    case enum_juju_twitter_pull_images_error.http:
        show_debug_message( "scr_example_pull_images_error: HTTP request failed" );
    break;
    
    case enum_juju_twitter_pull_images_error.busy:
        show_debug_message( "scr_example_pull_images_error: Upload already in progress" );
    break;
    
    
}
