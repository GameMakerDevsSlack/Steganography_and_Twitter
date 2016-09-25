///scr_juju_steg_pull_images( hashtag, number of tweets, success callback, error callback, timeout time, consumer key, consumer secret )
//  
//  Middleman script to automatically recover steganographic data from images pulled from Twitter.
//  
//  This function returns a list of buffers; each buffer contains data from images pulled from Twitter.
//  This list may or may not be empty depending on the success of the decoding operations.
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

with( scr_juju_twitter_pull_images( argument0, argument1, __scr_juju_steg_pull_images_callback, argument3, argument4, argument5, argument6 ) ) {
    steg_callback = argument2;
}
