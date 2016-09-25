///scr_juju_twitter_post_image( image title, tweet text, surface, success callback, error callback, timeout time, dev id )
//  
//  !!! Uploads are globally limited to 1,250 per 24 hours (approximately 13 uploads per 15 minutes). !!!
//  
//  Creates an object to upload an image to Twitter, and then opens a webpage that asks the user to tweet a link to
//  the uploaded image. The tweet can contain #hashtags, @usernames etc.
//  
//  This method requires an object to be active that manages the mechanics of HTTP. HTTP async events will be
//  triggered, this may interfere with other HTTP operations if run concurrently.
//  
//  The manager object will timeout after the amount of time defined by "timeout time", measured in ms.
//
//  Callback scripts are defined in "success callback" and "error callback". Use a blank string to opt out of
//  executing a callback script.
//      -  If there are no errors, "success callback" is executed, with no arguments.
//      -  If errors have occurred, "error callback" is executed, with argument0 being an error code as defined in
//         enum_juju_twitter_post_image_error
//  
//  In order to use the imgur API, a unique developer indentifier is needed. Please visit imgur.com and follow their
//  developer instructions to receive a dev id.
//  
//  This script *itself* return the id of the manager instance created.
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

enum enum_juju_twitter_post_image_state { uploading, complete, error };
enum enum_juju_twitter_post_image_error { timeout, destroyed, http, busy, imgur };

//If a manager object for this operation already exists, abort
if ( instance_exists( __obj_juju_twitter_post_image ) ) {
    if ( is_real( argument4 ) ) and ( script_exists( argument4 ) ) script_execute( argument4, enum_juju_twitter_post_image_error.busy );
    return noone;
}

with( instance_create( 0, 0, __obj_juju_twitter_post_image ) ) {
    
    persistent = true;
    
    title         = argument0;
    tweet_query   = argument1;
    surface       = argument2;
    if ( is_real( argument3 ) ) success_callback = argument3 else success_callback = noone;
    if ( is_real( argument4 ) )   error_callback = argument4 else   error_callback = noone;
    timeout_limit = argument5;
    
    creation_time = current_time;
    state = enum_juju_twitter_post_image_state.uploading;
    
    //Begin the upload to imgur
    http_id = scr_juju_imgur_http_request( title, surface, argument6 );
    
    return id;
    
}
