function ajaxSpinner(formEle, submitId){
  jQuery(document).on("ajax:beforeSend", formEle, function() {
    $(submitId).next(".spinner").show();
    $(submitId).hide();
  });
  jQuery(document).on("ajax:complete", formEle, function() {
    $(submitId).next(".spinner").hide();
    $(submitId).show();
  });
}

function ajaxSpinnerFile(formEle, submitId){
  $(submitId).next(".spinner").show();
  $(submitId).hide();
}

$(document).ready( function() {
  $(".select_field").custSelectBox();
  $(".datepicker").datepicker();
});

$(document).ready(function(){
  $("#q").autocomplete( {
    source: $("#q").attr('data-endpoint'),
    focus: function( event, ui ) {
      $( "#q" ).val( ui.item.label );
      return false;
    },
    select: function( event, ui ) {
      $( "#q" ).val( ui.item.label );
      $( "#q2" ).val( ui.item.id );
      return false;
    }
  });


});

$(document).on('change', '#course-select', function(){
  $.ajax({
    url: $(this).val(),
    dataType: 'script'
  });
});

function cancelPopover(element) {
 $(element).popover('hide');
}

$(document).on("submit", "#new-sport-manager-form", function(){
  sportSelectForManager = $("#account-select-sport").find(":selected").val();
  className = $("#account-select-sport").find(":selected").attr("class");

  if(sportSelectForManager == "0" || sportSelectForManager == 0 || sportSelectForManager == undefined){
    alert("Please select sport");
    return false;
      
  }else if(className == "organization-registered-sport"){
    alert("Already registered sport")
    return false;
  }else{
    sportName = $("#account-select-sport").find(":selected").text();
    $("#add-sport-name").val(sportName);
  }

});

$(function(){
  if($("#sub-varsity-name").length > 0){
    varsityName = $("#sub-varsity-selct-form").find(":selected").text();
    $("#sub-varsity-name").html(varsityName);
  }
})
