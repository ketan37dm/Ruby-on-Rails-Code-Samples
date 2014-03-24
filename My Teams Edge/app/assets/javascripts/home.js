$(document).ready(function(){
  $(document).on('change', '#sport-session', function(e){
    var ans = confirm("Do you want to move into other sport section?");
    if (ans == true) {
      var sport_id = $(this).val();
      if(sport_id){
        $.get('/home/change_sport_session?sport_id='+sport_id, function(data) {
        });
      }
    }
     else{
       var selected_option_value = $('select#sport-session option:selected').val();
       $('select#sport-session').val('' + selected_option_value);
     }
  });
})
