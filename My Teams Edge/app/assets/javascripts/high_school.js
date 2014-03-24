var sport_selected_index = number_of_users = user_counter = 0;
var sport_selected = [];


$(document).on("click", "#high_school_step", function(){
    var params = { 
        high_school : {
            name:  $("#payer_high_school_attributes_name").val(),
            city:  $("#payer_high_school_attributes_city").val(),
            state: $("#payer_high_school_attributes_state").val()
        }
    };

    $.ajax({
        url:  "/payers/validate_highschool_params",
        data: params,
        dataType: "script"
    });
});


$(document).on("click", "#add_team_step", function(){

    sport_id = $("#sport_selected").val();

    if(sport_id == "" || sport_id == undefined){
        alert("Please select a sport");
        return false;
    }

    if(sport_selected.indexOf(sport_id) != -1){
        alert("Sport already seleted.");
        return false;
    }else{
        sport_selected.push(sport_id);
    }

    sport_selected_index = sport_selected.indexOf(sport_id);

    var params = { 
        user : {
            sport_id: sport_id,
            first_name:  $("#user_fname_txt").val(),
            last_name: $("#user_lname_txt").val(),
            email: $("#user_email_txt").val()
        },
        high_school_name : $("#payer_high_school_attributes_name").val()
    };
    $.ajax({
        url:  "/payers/validate_user_params",
        data: params,
        dataType: "script"
    });       
});

$(document).on("click", ".edit_user_registration", function(){
        
        sport_id = $(this).attr("sport_selected_index");
        sport_selected_index = sport_selected.indexOf(sport_id);
        sport_selected.splice(sport_selected_index, 1);

        $(this).parent("div").hide();
        $(this).parent("div").next("div").show();
});

$(document).on("click", ".update_user_registration", function(){
    var user_counter = $(this).attr("count");
    
    sport_id = $("#sport_selected_" + user_counter).val();

    if(sport_id == "" || sport_id == undefined){
        return false;
    }
    if(sport_selected.indexOf(sport_id) != -1){
        alert("Sport already seleted.");
        return false;
    }else{
        sport_selected.push(sport_id);
    }

    sport_selected_index = sport_selected.indexOf(sport_id);

    var params = { 
        user : {
            sport_id:  sport_id,
            first_name:  $("#user_fname_txt_" + user_counter).val(),
            last_name: $("#user_lname_txt_" + user_counter).val(),
            email: $("#user_email_txt_" + user_counter).val()
        },
        user_counter: parseInt(user_counter),
        high_school_name : $("#payer_high_school_attributes_name").val()
    };

    $.ajax({
        url:  "/payers/validate_user_params",
        data: params,
        dataType: "script"
    });        
});


$(document).on("click", ".remove_user_registration", function(){

    sport_id = $(this).attr("sport_selected_index");
    sport_selected_index = sport_selected.indexOf(sport_id);
    sport_selected.splice(sport_selected_index, 1);

    $(this).parent("div").parent("div").remove();
    number_of_users -= 1;
});

$(document).on("click", "#new_user_step", function(){
    if(number_of_users == 0 || number_of_users == undefined){
        alert("Please add a team");
        return false;
    }else{
        $("#new_payer").formwizard("show", "step3");
    }
});


$(function(){
    $("#new_payer.high_school_form").formwizard({
        formPluginEnabled: true,
        historyEnabled: true,
        focusFirstInput : true,
        textSubmit : "JOIN MYTEAMSEDGE",
        formOptions :{
                        success: function(data){},
                        beforeSubmit: function(data){
                            validate_payer_details();
                            return false;
                        },
                        dataType: 'script'
                    }
    });
});

function validate_payer_details(){
    $('input[type=submit]').hide();
    $('.green-spinner').show();
    var params = {
        payer : {
            first_name:  $("#payer_first_name").val(),
            last_name:  $("#payer_last_name").val(),
            email: $("#payer_email").val(),
            credit_card: $("#card_number").val().length,
            cvv: $("#card_code").val().length,
            card_month: $("#card_month").val(),
            card_year: $("#card_year").val(),
        }
    };

    $.ajax({
        url:  "/payers/validate_payer_params",
        data: params,
        dataType: "script"
    }); 
}