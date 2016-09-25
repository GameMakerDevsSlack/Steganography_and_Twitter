///scr_juju_twitter_pull_images( search query, number of tweets, success callback, error callback, timeout time, consumer key, consumer secret )
//  
//  !!! Searches are limited to 180 per 15 minutes. !!!
//  
//  Creates an object to scan Twitter for images. This search can be customised as per Twitter's search API:
//  https://dev.twitter.com/rest/reference/get/search/tweets
//  
//  This method requires an object to be active that manages the mechanics of HTTP. HTTP async events will be
//  triggered, this may interfere with other HTTP operations if run concurrently.
//  
//  The manager object will timeout after the amount of time defined by "timeout time", measured in ms.
//  
//  Callback scripts are defined in "success callback" and "error callback". Use a blank string to opt out of
//  executing a callback script.
//      -  If there are no errors, "success callback" is executed, with argument0 being a list that containing
//         downloaded images stored as backgrounds.
//      -  If errors have occurred, "error callback" is executed, with argument0 being an error code as defined in
//         enum_juju_twitter_pull_images_error
//  
//  "consumer key" and "consumer secret" are the unique developer authorisation codes provided by Twitter when
//  you register as a developer and create an application. For more information:
//  https://dev.twitter.com/
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

enum enum_juju_twitter_pull_images_state { token, tweets, image, complete, error };
enum enum_juju_twitter_pull_images_error { timeout, token, no_tweets, no_images, destroyed, http, busy };

//If a manager object for this operation already exists, abort
if ( instance_exists( __obj_juju_twitter_pull_images ) ) {
    if ( is_real( argument3 ) ) and ( script_exists( argument3 ) ) script_execute( argument3, enum_juju_twitter_pull_images_error.busy );
    return noone;
}

with( instance_create( 0, 0, __obj_juju_twitter_pull_images ) ) {
    
    persistent = true;
    
    search_query    = argument0;
    collect_count   = argument1;
    if ( is_real( argument2 ) ) success_callback = argument2 else success_callback = noone;
    if ( is_real( argument3 ) )   error_callback = argument3 else   error_callback = noone;
    timeout_limit   = argument4;
    consumer_key    = argument5;
    consumer_secret = argument6;
    
    state           = enum_juju_twitter_pull_images_state.token;
    creation_time   = current_time;
    lst_images      = ds_list_create();
    lst_backgrounds = ds_list_create();
    image           = 0;
    png_location    = "";
    
    //Send an HTTP request to collect an access token
    var map = ds_map_create();
    ds_map_add( map, "Authorization", "Basic " + base64_encode( consumer_key + ":" + consumer_secret ) );
    ds_map_add( map, "Content-Type", "application/x-www-form-urlencoded;charset=UTF-8." );
    http_id = http_request( "https://api.twitter.com/oauth2/token/", "POST", map, "grant_type=client_credentials" );
    ds_map_destroy( map );
    
    return id;
    
}
