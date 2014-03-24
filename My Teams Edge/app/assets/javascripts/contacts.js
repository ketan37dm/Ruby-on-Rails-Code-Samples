$(document).on("click", '#cancel-add-personal-contact-trigger', function(){
  $("#add-contact").modal('hide');
  return false;
});

$(document).on("click", '#cancel-add-document-trigger', function(){
  $("#add-document").modal('hide');
  return false;
});

$(document).on("click", '#cancel-add-course-trigger', function(){
  $("#add-course").modal('hide');
  return false;
});

$(document).on("click", '#cancel-add-course-event-trigger', function(){
  $("#upcoming-event").modal('hide');
  return false;
});