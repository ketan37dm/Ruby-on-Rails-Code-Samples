var subscription;

jQuery(function() {
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));
  return subscription.setupForm();
});

subscription = {
  setupForm: function() {
    return $('.card_form').submit(function() {
      $('input[type=submit]').attr('disabled', true);
      $('input[type=submit]').hide();
      $('.green-spinner').show();
      if ($('#card_number').length) {
        subscription.processCard();
        return false;
      } else {
        return true;
      }
    });
  },
  processCard: function() {
    var card;
    card = {
      number: $('#card_number').val(),
      cvc: $('#card_code').val(),
      expMonth: $('#card_month').val(),
      expYear: $('#card_year').val()
    };
    return Stripe.createToken(card, subscription.handleStripeResponse);
  },
  handleStripeResponse: function(status, response) {
    if (status === 200) {
      $('#payer_stripe_token').val(response.id);
      return $('.card_form')[0].submit();
    } else {
      $('#stripe_error').html(response.error.message);
      $('#stripe_error').show();
      $('input[type=submit]').attr('disabled', false);
      $('input[type=submit]').show();
      $('.green-spinner').hide();
    }
  }
};


$(document).on('click', 'form .same-person-no', function(e){
  $('#payer_first_name').removeAttr('disabled');
  $('#payer_last_name').removeAttr('disabled');
  $('#payer_email').removeAttr('disabled');
  $('#payer_is_same_user').val('no');
  $('.not-same-person').show();
  $(this).addClass('same-person-link');
  $('form .same-person-yes').removeClass('same-person-link');
  
});

$(document).on('click', 'form .same-person-yes', function(e){
  $(this).addClass('same-person-link');
  $('form .same-person-no').removeClass('same-person-link');
  $('#payer_first_name').attr('disabled', 'disabled');
  $('#payer_last_name').attr('disabled', 'disabled');
  $('#payer_email').attr('disabled', 'disabled');
  $('#payer_is_same_user').val('yes');
  $('.not-same-person').hide();
});


$(document).ready(function(){
  $('#payer_organization_name').bind('railsAutocomplete.select', function(event, data){
    /* Do something here */
    $('#payer_city').attr('readonly', true);
    $('#payer_state').attr('readonly', true);
    $('#payer_level').attr('readonly', true);
    $("option[value='High School']").attr('disabled', 'disabled');
    $("option[value='Other']").attr('disabled', 'disabled');

    $('select#payer_state option:not(:selected)').attr('disabled', 'disabled');
  });

  $('#payer_organization_name').keypress(function(){
    $('#payer_city').removeAttr('readonly');
    $('#payer_state').removeAttr('readonly');
    $('#payer_level').removeAttr('readonly');
    $("option[value='High School']").removeAttr('disabled');
    $("option[value='Other']").removeAttr('disabled');
    $('select#payer_state option:not(:selected)').removeAttr('disabled');
  });
 
});
































