$(document).ready(function(){
    var slideObserver = new SlideObserver();
    slideObserver.initialize();
});

function SlideObserver(){
    this.initialize = function(){
        if($('.quotes').length){
            this.hookQuotes();
        }

        if($('.sample-pitches').length){
            this.hookSamplePitches();
        }
    };

    this.hookQuotes = function(){
        $(".quotes-container").cycle({
            fx:      'turnDown',
            delay: -2000,
            pause: true,
            timeout: 5000
        });
    };

    this.hookSamplePitches = function(){
        $(".sample-pitch-container").cycle({
            fx:      'turnDown',
            delay: -2000,
            pause: true,
            timeout: 45000,
            next: '.next',
            prev: '.prev'
        });
    };
}