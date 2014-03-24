$(document).ready(function(){
    var like = new Like();
    like.initialize();
});

function Like(){
    this.initialize = function(){
        this.hookLikeCreation();
    };

    this.hookLikeCreation = function(){
        var current = this;
        $('body').on('click', '.myp-like', function(){
            var $link = $(this);
            $.ajax({
                type: 'POST',
                url: $link.attr('href'),
                success: function(){
                    current.increaseLikeCount($link);
                },
                error: function(){
                    alert('An error occured. Please refresh your page!');
                }
            });

            return false;
        });
    };

    this.hookDummyParam = function(){
        $('body').on("click", '.vote-up-dummy-link', function(){
            var url = $(this).attr('href').split("?")[0];
            var param = "";
            if($(this).prev('.show-redirect').length){
                param = "?show_redirect=true"
            }
            console.log((url + param))

            $(this).attr("href", (url + param));
        });
    };

    this.increaseLikeCount = function($element){
        var $pitchCountContainer = $element.parents('.internal-right-pitch').first().find('.pitch-count');
        var $pitchSizeContainer = $pitchCountContainer.find('.pitch-sizing');
        var existingCount = Number($pitchSizeContainer.text());
        $pitchSizeContainer.text((existingCount + 1).toString());

        $element.remove();
    };
}
