///__scr_juju_twitter_pull_images_http( [report level] )
//  
//  Internal script. Do not modify.
//  
//  "report level" is an optional argument that controls how much information is sent to the compile form:
//    0:  No reporting, not even errors
//    1:  Report only errors. (Default)
//    2:  Reports errors and the result of most recieved data.
//    3:  Reports all information, including potentially sensitive information.
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

var asyncLoad = async_load;

//Set the detail level to 1 if none has been specified
if ( argument_count > 0 ) var reporting = argument[0] else reporting = 1;

var ID          = ds_map_find_value( asyncLoad, "id" );
var status      = ds_map_find_value( asyncLoad, "status" );
var result      = ds_map_find_value( asyncLoad, "result" );
var url         = ds_map_find_value( asyncLoad, "url" );
var http_status = ds_map_find_value( asyncLoad, "http_status" );

//If there's been an error with the HTTP request
if ( status < 0 ) {
    
    __scr_juju_twitter_pull_images_destroy_error( enum_juju_twitter_pull_images_error.http );
    
} else {
    
    //If there's information in the received HTTP message
    if ( !is_undefined( result ) ) {
        
        if ( reporting >= 3 ) show_debug_message( result );
        
        //Execute a different behaviour depending on what processing state we're in
        switch( state ) {
            
            //If we're asked for a token...
            case enum_juju_twitter_pull_images_state.token:
                
                //Decode the message into a JSON
                var json = json_decode( result );
                
                //Try to find token information
                var tokenType = ds_map_find_value( json, "token_type" );
                if ( !is_undefined( tokenType ) ) {
                    
                    //Check the token format
                    if ( tokenType == "bearer" ) {
                        
                        //Try to find the access token itself
                        var token = ds_map_find_value( json, "access_token" );
                        if ( !is_undefined( token ) ) {
                            
                            if ( reporting >= 3 ) show_debug_message( "scr_juju_twitter_pull_images_http_async: token received " + string( token ) );
                            
                            //Execute the search query using our new access token
                            var map = ds_map_create();
                            ds_map_add( map, "Authorization", "Bearer " + token );
                            http_id = http_request( "https://api.twitter.com/1.1/search/tweets.json?" + search_query + "&count=" + string( collect_count ), "GET", map, "" );
                            ds_map_destroy( map );
                            
                            state = enum_juju_twitter_pull_images_state.tweets;
                        
                        //If we can't find the explicit token data, abort
                        } else {
                            
                            __scr_juju_twitter_pull_images_destroy_error( enum_juju_twitter_pull_images_error.token );
                            
                        }
                        
                    //If we don't recognise the token format, abort
                    } else {
                        
                        __scr_juju_twitter_pull_images_destroy_error( enum_juju_twitter_pull_images_error.token );
                        
                    }
                
                //If there's no token information, abort  
                } else {
                    
                    __scr_juju_twitter_pull_images_destroy_error( enum_juju_twitter_pull_images_error.token );
                    
                }
                
                ds_map_destroy( json );
                
            break;
            
            //If we've made a search on Twitter...
            case enum_juju_twitter_pull_images_state.tweets:
                
                //Decode the message into a JSON
                var json = json_decode( result );
                
                var list = ds_map_find_value( json, "statuses" );
                if ( !is_undefined( list ) ) {
                    
                    var size = ds_list_size( list );
                    if ( reporting >= 2 ) show_debug_message( "scr_juju_twitter_pull_images_http_async: " + string( size ) + " tweets returned" );
                    
                    //Go through each tweet
                    for( var i = 0; i < size; i++ ) {
                        
                        var ds_root = ds_map_find_value( ds_list_find_value( list, i ), "entities" );
                        if ( !is_undefined( ds_root ) ) {
                            
                            //Check for URLs attached to media (images/video etc)
                            ds = ds_map_find_value( ds_root, "media" );
                            if ( !is_undefined( ds ) ) {
                                
                                //Iterate over every media URL
                                var media_size = ds_list_size( ds );
                                for( var j = 0; j < size; j++ ) {
                                    
                                    var url = ds_map_find_value( ds_list_find_value( ds, j ), "media_url" );
                                    if ( !is_undefined( url ) ) {
                                        
                                        //Queue this URL
                                        ds_list_add( lst_images, url );
                                        if ( reporting >= 3 ) show_debug_message( "scr_juju_twitter_pull_images_http_async: Queuing image " + url );
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            //Look for URLs that have been linked to in the tweet (this can be any number of possible things)
                            ds = ds_map_find_value( ds_root, "urls" );
                            if ( !is_undefined( ds ) ) {
                                
                                //Iterate over every URL
                                var urls_size = ds_list_size( ds );
                                for( var j = 0; j < size; j++ ) {
                                    
                                    //Grab the full URL
                                    var url = ds_map_find_value( ds_list_find_value( ds, j ), "expanded_url" );
                                    if ( !is_undefined( url ) ) {
                                        
                                        var length = string_length( url );
                                        var filetype = string_copy( url, length - 3, 4 );
                                        
                                        //If the file is a .png or .jpg, queue it for download
                                        if ( filetype == ".png" ) or ( filetype == ".jpg" ) {
                                            
                                            if ( ds_list_find_index( lst_images, url ) < 0 ) {
                                                ds_list_add( lst_images, url );
                                                if ( reporting >= 3 ) show_debug_message( "scr_juju_twitter_pull_images_http_async: Queuing image " + url );
                                            }
                                        
                                        //If the file isn't expressly an image, search for some mention of imgur instead
                                        } else if ( string_pos( "imgur", url ) >= 1 ) {
                                            
                                            //Try to find the final backslash
                                            if ( string_copy( url, length - 7, 1 ) == "/" ) {
                                                
                                                //Grab the 7-character location code and queue it
                                                url = "http://i.imgur.com/" + string_copy( url, length - 6, 7 ) + ".png";
                                                
                                                if ( ds_list_find_index( lst_images, url ) < 0 ) {
                                                    ds_list_add( lst_images, url );
                                                    if ( reporting >= 3 ) show_debug_message( "scr_juju_twitter_pull_images_http_async: Queuing image " + url );
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                if ( size <= 0 ) {
                    
                    __scr_juju_twitter_pull_images_destroy_error( enum_juju_twitter_pull_images_error.no_tweets );
                    
                } else if ( ds_list_size( lst_images ) > 0 ) {
                    
                    state = enum_juju_twitter_pull_images_state.image;
                    image = 0;
                    
                    if ( reporting >= 2 ) show_debug_message( "scr_juju_twitter_pull_images_http_async: " + string( ds_list_size( lst_images ) ) + " images found" );
                    
                    //Begin downloading procedure - immediately request an image file from the link we've colllected
                    //Find a save location that won't overwrite another file
                    png_location = scr_safe_save( "", ".png" );
                    
                    //Try to download the URL
                    var url = ds_list_find_value( lst_images, image );
                    http_id = http_get_file( url, png_location );
                    if ( reporting >= 2 ) show_debug_message( "scr_juju_twitter_pull_images_http_async: Downloading image " + url + " to " + png_location );
                    
                } else {
                    
                    __scr_juju_twitter_pull_images_destroy_error( enum_juju_twitter_pull_images_error.no_images );
                    
                }
                
            break;
            
            //If we're downloading an image...
            case enum_juju_twitter_pull_images_state.image:
                
                //Go to the expected download location and attempt to load the file into the game
                var back = background_add( png_location, false, false );
                file_delete( png_location );
                ds_list_add( lst_backgrounds, back );
                if ( reporting >= 3 ) show_debug_message( "scr_juju_twitter_pull_images_http_async: " + png_location + " add as background {" + string( back ) + "}" );
                
                //Move onto the next image
                image++;
                
                //If we've downloaded all the images...
                if ( image >= ds_list_size( lst_images ) ) {
                    
                    if ( reporting >= 1 ) show_debug_message( "scr_juju_twitter_pull_images_http_async: Operation took " + string( current_time - creation_time ) + "ms" );
                    __scr_juju_twitter_pull_images_destroy_success();
                
                //...otherwise keep going
                } else {
                    
                    //Find a save location that won't overwrite another file
                    png_location = scr_safe_save( "", ".png" );
                    
                    //Try to download the URL
                    var url = ds_list_find_value( lst_images, image );
                    http_id = http_get_file( url, png_location );
                    if ( reporting >= 2 ) show_debug_message( "scr_juju_twitter_pull_images_http_async: Downloading image " + url + " to " + png_location );
                    
                }
                
            break;
            
            //If we're in an unsupported state...
            default:
                
                __scr_juju_twitter_pull_images_destroy_error( enum_juju_twitter_pull_images_error.http );
                
            break;
            
        }
        
    //If there's no information in the HTTP message...
    } else if ( reporting >= 2 ) {
        
        show_debug_message( "scr_juju_twitter_pull_images_http_async: Waiting..." );
        
    }

}
