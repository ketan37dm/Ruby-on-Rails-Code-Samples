// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery.1.8.3
//= require jquery_ujs
//= require jquery_contactable_plugin/jquery.validate
//= require jquery_contactable_plugin/jquery.contactable
//= require jquery.placeholder.min
//= require jquery.cycle
////= require easing/jquery.easing-1.3
//= require twitter/bootstrap
//= require registrations
//= require pitches
//= require comments
//= require slides.observers
//= require endless_page
//= require likes
//= require billboard
//= require slidetounlock
//= require polls
//= require home
//= require jquery.scrollTo.min

/**
 * Hook the feedback form
 */
$(document).ready(function(){
    $('#contactable').contactable({
        subject: 'Partner Feedback'
    });

    $('body').on('click', '.fb-share-link', function(){
        postToFeed($(this).attr('fb-post-link'), $(this).attr('fb-logo'), $(this).attr('fb-description'));
        return false;
    });

    setTimeout(function(){
        $('#notification .alert').alert('close');
    },2000);
    
});
