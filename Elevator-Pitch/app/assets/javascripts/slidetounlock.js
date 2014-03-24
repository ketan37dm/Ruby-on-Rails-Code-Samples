$(document).ready(function() {
    if($('#slider').length){
        $("#slider").draggable({
            axis: 'x',
            containment: 'parent',
            drag: function(event, ui) {
                if (ui.position.left > 145) {
                    $('.locked').removeClass('bold');
                    $('.unlocked').addClass('bold');
                            
                } else {
            // Apparently Safari isn't allowing partial opacity on text with background clip? Not sure.
            // $("h2 span").css("opacity", 100 - (ui.position.left / 5))
            }
            },
            stop: function(event, ui) {
                if (ui.position.left < 145) {
				
                    $('.locked').addClass('bold');
                    $('.unlocked').removeClass('bold');
				
                }
            }
        });
    }
});
