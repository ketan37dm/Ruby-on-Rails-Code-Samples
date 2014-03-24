var currentPage = 1;
var pathname = window.location.pathname;

function checkScroll(pathname) {
  currentPage++;
  $.ajax({
    type : "GET",
    url : pathname + '?page=' + currentPage,
    data: "format=json"
  }).done( function (data) {
    $('#results').append(data['content']);
    $("#loading").hide();
    IN.parse(document.getElementsByClassName('page-' + data['page'])[0]);
  });
}

$(window).scroll(function(){
  if ($(window).scrollTop() == $(document).height() - $(window).height()){
    if ( currentPage < ( $('.pagination').children().children().length - 2 ) ) { $("#loading").show(); checkScroll(pathname); }
  }
});

$(document).ready( function () { 
  $("#loading").hide();
  $(".pagination").hide();
});
