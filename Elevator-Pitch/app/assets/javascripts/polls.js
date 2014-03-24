$(document).ready(function(){
    var poll = new Poll();
    poll.initialize();
});

function Poll(){
    var $poll = $('.poll');
    this.initialize = function(){
        if($poll.length){
            this.setAnswerValue();
            this.hookFormSubmission();
        }
    };

    this.setAnswerValue = function(){
        $('.poll').find('.btn').click(function(){
            $('#poll_result_poll_answer_id').val($(this).attr('data-val'));
            $(this).parents('form').first().submit();
        });
    };

    this.hookFormSubmission = function(){
        $('#poll_form').submit(function(event){
            event.preventDefault();
            $.ajax({
                url:  $(this).attr('action'),
                type: 'POST',
                data: $(this).serialize(),
                error: function(data) {
                    $('.poll').text('There was a problem submitting your choice.');
                },
                success: function(data){
                    $('.poll').html(data['message']);
                    setTimeout(function(){
                        $('.poll').remove();
                    },5000);
                }
            });

        })

    };
}
