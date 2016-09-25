///__scr_juju_twitter_post_image_http()
//  
//  Internal script. Do not modify.
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

//If the HTTP message was for us
if ( ds_map_find_value( async_load, "id" ) == http_id ) {
    
    //If there was an error...
    if ( ds_map_find_value( async_load, "status" ) < 0 ) {
        
        __scr_juju_twitter_post_image_destroy_error( enum_juju_twitter_post_image_error.http );
    
    //If the HTTP request did not result in an error  
    } else {
        
        //Decode the JSON
        var map = json_decode( ds_map_find_value( async_load, "result" ) );
        
        //Try to find "data" in the JSON
        map = ds_map_find_value( map, "data" );
        if ( !is_undefined( map ) ) {
            
            //Try to find "id" in the JSON
            var image_id = ds_map_find_value( map, "id" );
            if ( !is_undefined( image_id ) ) {
                
                //Immediately open a webpage asking the user to tweet the uploaded image
                url_open( "https://twitter.com/intent/tweet?" + tweet_query + "&url=http://www.imgur.com/" + image_id );
                __scr_juju_twitter_post_image_destroy_success();
                
            //If we could not find "id", report an error
            } else {
                
                __scr_juju_twitter_post_image_destroy_error( enum_juju_twitter_post_image_error.imgur );
                
            }
        
        //If we could not find "data", report an error
        } else {
            
            __scr_juju_twitter_post_image_destroy_error( enum_juju_twitter_post_image_error.imgur );
            
        }
        
    }
    
    //Make sure we don't accidentally try to receive HTTP messages not intended for this script
    http_id = noone;
    
}
