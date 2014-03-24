$(document).ready(function(){
    var billboard = new Billboard();
    billboard.initialize();
});

function Billboard(){
    var $billboard = $('.billboard-container');

    this.initialize = function(){
        if($billboard.length){
            $('.show-billboard').hide();
            this.hookClose();
            this.hookOpen();
        }
    };

    this.hookClose = function(){
        $('.billboard-container .close').click(function(){
            $('.billboard-container').animate({
                opacity: 'toggle',
                width: 'toggle'
            }, "slow", function(){
                $('.show-billboard').animate({
                    opacity: 'toggle',
                    width: 'toggle'
                });
            });
        });
    };

    this.hookOpen = function(){
        $('.show-billboard').click(function(){
            $('.billboard-container').animate({
                opacity: 'toggle',
                width: 'toggle'
            }, "slow", function(){
                $('.show-billboard').animate({
                    opacity: 'toggle',
                    width: 'toggle'
                });
            });
        });
    };
}

