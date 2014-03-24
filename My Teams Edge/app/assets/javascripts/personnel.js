var viewingUnit = false;

$(function(){
  $.fn.doesExist = function(){
    return jQuery(this).length > 0;
  };

  if($("#personnel-left-block").doesExist()){
    //send and ajax call to update the the let hand side
    updatePersonnelUsersLeftBlock();
  }

  $('.cancel').click(function(){
    $('.new-unit').modal('hide');
  });

  $('#new-unit-trigger').click(function(){
    $('#new-unit').modal();
    $('#custom_sports_unit_unit_name').val("");
  });

  $('#create-unit-trigger').click(function(){
    $('#new-unit').modal('hide');
    $('#new-unit-2').modal();
  });

  $('.cancel').click(function(){
    $("#create_unit_errors").html('');
    $('.new-unit').modal('hide');
    return false;
  });

  $('#new-unit-trigger').click(function(){
    $('#new-unit').modal();
  });

  $(document).on("click", "#add_coach_trigger", function(){
    $('#add-coach').modal();
  });

  $(document).on("click", ".cancel-trigger", function(){
    $('#add-entity').modal('hide');
    $('#send-email').modal('hide');
    $('#resend-invite').modal('hide');    
    return false;
  });
});


function updatePersonnelUsersLeftBlock(updateBlock){
  var params = { 
    role: '',
    update_block: updateBlock
  }

  if(showPlayers == "true" || showPlayers == true){
    params["role"] = "player";
  }

  $.ajax({
    url:  "/coach/personnel/list_roles_with_user_count",
    dataType: "script",
    data: params
  });
}

function updatePersonnelUsersRightBlock(role){
  if(role == '' || role == undefined){
    return false;
  }

  $.ajax({
    url:  "/coach/personnel/list_users_rolewise/" + role,
    dataType: "script"
  });
}

function showUsersOnPersonnelPage(){
  updatePersonnelUsersLeftBlock();
}

function showUnitsOnPersonnelPage(){
  updatePersonnelUnitsLeftBlock();  
}

function updatePersonnelUnitsLeftBlock(updateBlock){
  var params = {
    update_block: updateBlock
  };
  
  $.ajax({
    url:  "/coach/personnel/list_units_with_user_count",
    dataType: "script",
    data: params

  });
}

function updatePersonnelUnitsRigtBlock(unit){
  if(unit == '' || unit == undefined){
    return false;
  }

  $.ajax({
    url:  "/coach/personnel/list_users_unitwise/" + unit,
    dataType: "script"
  });
}


$(document).on("click", ".user-list-li", function(){
  var emailVal = $(this).prev('span').attr('email');
  var imageVal = $(this).prev('img').attr('src');
  userEmails.push(emailVal);
  userImages.push(imageVal);
  index = selectedEmails.indexOf(emailVal);
  selectedEmails.splice(index, 1);
  $(this).parent('li').remove();

  if(selectedEmails.length == 0){
    $("#add-users-submit-button").hide();
  }else{
    $("#add-users-submit-button").show();
  }
});

$(document).on("click", "#add-users-submit-button", function(){
  $("#users-for-unit").val(selectedEmails);
  return true;
});


$(document).on("click", ".list-users-rolewise", function(){
  
  $(".list-users-rolewise").each(function(){
    $(this).removeClass("selected");
  });

  $(this).addClass("selected");
  role = $(this).attr("role");
  updatePersonnelUsersRightBlock(role);

  return false;
});

$(document).on("click", ".list-users-unitwise", function(){
  
  $(".list-users-unitwise").each(function(){
    $(this).removeClass("selected");
  });

  $(this).addClass("selected");
  unit = $(this).attr("unit");
  updatePersonnelUnitsRigtBlock(unit);

  return false;
});

$(document).on("click", "#view-users-trigger", function(){
  viewingUnit = false;
  showUsersOnPersonnelPage();
});

$(document).on("click", "#view-units-trigger", function(){
  viewingUnit = true;
  showUnitsOnPersonnelPage();
});

$(document).on("click", ".delete-unit-ajax", function(){
  $.ajax({
    type: "POST",
    url : $(this).attr('data-target'),
    data: "_method=delete"
  });
});

function unitToUser(){
  $('.view-unit').popover({html: true, trigger: 'click'});
  $('.cancel').click(function(){
    $('.new-unit').modal('hide');
    $('.add-to-unit').modal('hide');
  });

  $('#new-unit-trigger').click(function(){
    $('#new-unit').modal();
  });

  $('#create-unit-trigger').click(function(){
    $('#new-unit').modal('hide');
    $('#new-unit-2').modal();
  });

  $("#add-to-unit-trigger").live("click", function(){ 
    $('#add-to-unit').modal();
  });
}


//$(document).ready(function(){
  //$('.view-unit').popover({html: true, trigger: 'click'});
//});

//$('.cancel').click(function(){
  //$('.new-unit').modal('hide');
  //$('.add-to-unit').modal('hide');
//});

//$('#new-unit-trigger').click(function(){
  //$('#new-unit').modal();
//});

//$('#create-unit-trigger').click(function(){
  //$('#new-unit').modal('hide');
  //$('#new-unit-2').modal();
//});

//$("#add-to-unit-trigger").live("click", function(){ 
  //$('#add-to-unit').modal();
//});

