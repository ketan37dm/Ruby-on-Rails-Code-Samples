$(document).ready(function(){
    $('#registration_form').submit(function() {
        if($(".unlocked").hasClass('bold')){
            return true;
        }
        else{
            alert("Slide to unlock first");
            return false;
        }
    })
});