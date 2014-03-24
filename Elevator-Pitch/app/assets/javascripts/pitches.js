$(document).ready(function () {
    var pitch = new Pitch();
    pitch.initialize();
});

function Pitch(){
    var $pitchDescription = $('#pitch_description');

    this.initialize = function(){
        if($pitchDescription.length){
            this.hookOnLoadWordcalculator(this);
            this.hookKeyup(this);
            this.hookSubmitClick();
            this.hookFormSubmission(this);
            this.hookPitchHelperAnimation();
        }
    };

    this.hookOnLoadWordcalculator = function(current){
        var $description = $("#pitch_description");
        current.populateRemainingWords($description);
    };

    this.hookKeyup = function(current){
        var $description = $("#pitch_description");
        $description.keyup(function() {
            current.populateRemainingWords($description);
        });
    };

    this.hookSubmitClick = function(){
        $('#pitch_form input[type=submit]').click(function(){
            $('#pitch_status').val($(this).val());
            return pitch_word_limit();
        });
    };

    this.hookFormSubmission = function(current){
        var $description = $("#pitch_description");
        $('#pitch_form').submit(function(){
            var wordCount = current.getWordCount($description);

            if(wordCount < 0){
                alert('You have exceeded the number of words allowed for your pitch.');
                return false;
            }
        });
    };

    this.hookPitchHelperAnimation = function(){
        $('body').on('click', '.help-link', function(){
            $('.getting-started').slideToggle(500);
            $('.placeholder-pitch').remove();
            var $firstPitch = $('.sample-pitches').find('.sample-pitch').first();
			$firstPitch.show();

            // var $temp = $("<div />");
            //             var $firstPitch = $('.sample-pitches').find('.sample-pitch').first().clone();
            //             $firstPitch.attr('style', '');
            //             $firstPitch.addClass('placeholder-pitch');
            //             $temp.append($firstPitch);
            // 
            //             $('.sample-pitches').before($temp.html());
            //             $('.sample-pitches .prev').hide();
            //             $('.sample-pitches .next').hide();
        });
    };


   

    this.populateRemainingWords = function($descriptionBox){
        var remainingWordCount = this.getWordCount($descriptionBox);
        if(remainingWordCount < 0){
            $('.word-counter').addClass('error');
            $('.word-counter').html("<span class='inline-helper'>You have exceeded the number words allowed.</span>");
        }else{
            $('.word-counter').removeClass('error');
            $('.word-counter').html("<span>" + remainingWordCount + " word(s) remaining.</span>");
        }
    };

    this.getWordCount = function($descriptionBox){
        var maxWordLimit = 250;
        var wordcount = $descriptionBox.val().split(/\b[\s,\.-:;]*/).length - 1;
        return (maxWordLimit - wordcount);
    };
}
