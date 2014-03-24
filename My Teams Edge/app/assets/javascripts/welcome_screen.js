$(function(){

    $('#welcome').modal({
        escapeClose: false,
        clickClose: false,
        showClose: false
    });

    $('.btn-upload-photo').click(function(){
        $('#welcome').modal('hide');
    });

    $('.btn-add-users').click(function(){
        $('#welcome').modal('hide');
    });

    $('.btn-add-opponents').click(function(){
        $('#welcome').modal('hide');
    });

    $('.back-link').click(function(){
        $('#upload-photo').modal('hide');
        $('#add-users').modal('hide');
        $('#add-opponents').modal('hide');
    });

    $('.btn-update-pinfo').click(function(){
      $('#welcome').modal('hide');
    });

    $('.btn-add-courses').click(function(){
      $('#welcome').modal('hide');
    });

    $('.back-link').click(function(){
      //$('#upload-photo').modal('hide');
      $('#update-pinfo').modal('hide');
      $('#add-courses').modal('hide');
    });

    $('#go-to-home').click(function(){
      $('#welcome').modal('hide');
    });

    $('body').mousemove(function () {
        var htmlStr = $(".file").val();
        if(htmlStr!='') {
            if ($.browser.msie) {
                $('.fileinputs input').val(htmlStr);
            } else {
                $('.fileinputs input').attr('placeholder',htmlStr);
            }
        }
    });

    $(document).on("click", ".welcome_submit_form", function() {
        $(this).next("div").show();
        $(this).hide();
    });


});

function show_welcome_submit_button(){
    $(".welcome_submit_form").show();
    $(".welcome_submit_form").next("div").hide();
}
