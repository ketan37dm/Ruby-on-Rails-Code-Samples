$(document).ready(function(){
    var comment = new Comment();
    comment.initialize();
});

function Comment(){
    var $commentsForm = $('#new-comment-form');
    var $loginCover = $('.login-cover');
    $loginCover.hide();
    
    this.initialize = function(){
        if($commentsForm.length){
            this.hookSubmission();
        }

        var $isNotLoggedIn = $('#user-not-logged-in').length;
        if($isNotLoggedIn){
            this.hookCommentCover();
            this.registerPitchCallbackUrl();
        }
    };

    this.registerPitchCallbackUrl = function(){
        $('.pitch-callback-url').click(function(){
            var $link = $(this);
           $.ajax({
              url: $('#pitch_callback_url').val(),
              data: ("pitch_callback_url=" + window.location),
              success: function(){
                  window.location = $link.attr('href');
              }
           });

           return false;
        });
    };

    this.hookCommentCover = function(){
        $('body').on('mouseover', '.new-comment-wrapper', function(){
           $commentsForm.hide();
           $loginCover.show();
        });

        $('body').on('mouseout', '.login-cover', function(){
           $commentsForm.show();
           $loginCover.hide();
        });
    };

    this.hookSubmission = function(){
        var current = this;
        $('body').on('submit', '#new-comment-form', function(){
            var $form = $('#new-comment-form');
            $.ajax({
                url: $form.attr('action'),
                type: 'POST',
                data: $form.serialize(),
                beforeSend: function(){
                    $form.find('input[type=submit]').toggle();
                    $form.find('.please-wait').removeClass('display-none');
                },
                success: function(data){
                    current.addComment(data);
                    current.reset($form);
                    current.removeError($form);
                },
                error: function(){
                    current.removeError($form);
                    var $errorContainer = $('<div />');
                    var $errorSection = $('<div />');
                    $errorSection.addClass('error-section');
                    $errorSection.append('Failed to add the comment. Please refresh this page and try again!');
                    $errorContainer.append($errorSection);
                    $form.prepend($errorContainer.html());
                },
                complete: function(){
                    $form.find('input[type=submit]').toggle();
                    $form.find('.please-wait').addClass('display-none');
                }
            });

            return false;
        });
    };

    this.addComment = function(data){
        var $commentContainer = $('<div />');
        $commentContainer.append("<h4 class='comment-index'><em>Your comment</em></h4>")

        var $innerContainer = $('<div />');
        $innerContainer.addClass('top-spacer comment-item');
        
        var $firstLine = $('<div />')
        $firstLine.append("<div><span class='comment-author'>" + data['commentator_name'] + "</span><br/><span class='post-timestamp'>" + data['comment_timestamp'] + "</span></div>")  ;

        var $comment = $('<div />')
        $comment.addClass('desc-padding');
        $comment.append(data['comment']);

        $innerContainer.append($firstLine);
        $innerContainer.append($comment);
        $commentContainer.append($innerContainer);

        $('.comments-endpoint').append($commentContainer.html());
        $('.no-comments').hide();
    };

    this.reset = function($form){
        $form.find('input:text, input:password, input:file, select').val('');
        $form.find('input:radio, input:checkbox')
        .removeAttr('checked').removeAttr('selected');
        $form.find('textarea').val('');
    };

    this.removeError = function($form){
        $form.find('.error-section').remove();
    };
}
