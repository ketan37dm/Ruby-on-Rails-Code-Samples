$(document).ready(function(){
    var pitchListing = new PitchListing();
    pitchListing.initialize();
});

function PitchListing(){
    var $buttonContainer = $('.button-container');
    this.initialize = function(){
        if($buttonContainer.length){
            $('.button-container button').button();
            this.positionBubble(this);
            this.hookSorting(this);
			this.hookSearch(this);
            this.hookCategorization(this);
        }
    };

    this.positionBubble = function(){
        offset = $('.bubble em').offset();
        $('.bubble img').css('top', offset.top - 120);
        $('.bubble img').css('left', offset.left - 40);
        $('.bubble img').show('fadeIn');
    };

   this.searchFilterParams = function(){
	  params = "format=json" + 
            "&sort_type=" + $('#sort_type').val()+
            "&category_id=" + $('#pitch_type').val()+
            "&tags="+$('#searchBox').val();
      return params;
    };

    var searchFilterError = "<div class='error'>We're sorry. Something went wrong! <br/>We've been notified about this and our team is on it.<br/>In the mean while, please <a href='/'>refresh</a> the page.</div>";

    this.hookCategorization = function(current){
        $('body').on('click', '.category button', function(){
            $('#pitch_type').val($(this).val());
            var $button  = $(this);
            search(current);
            highlightButton($('.category'),$button);
        });
    };

    this.hookSorting = function(current){
        $('body').on('click', '.button-container button', function(){
            $('#sort_type').val($(this).val());
            var $button  = $(this);

            search(current);
            highlightButton($('.filter'),$button);
        });
    };

	this.hookSearch = function(current){
		 $('#searchBox').typeahead({ 
			source: function(query, process) {
			        return $.ajax({
			            url: '/lookup',
			            type: 'get',
			            data: {query: query},
			            dataType: 'json',
			            success: function(json) {
			                return typeof json.options == 'undefined' ? false : process(json.options);
			            }
			        });
			    },
			minLength: 3,
			items: 10
		  });

		  $('#searchBox').change(function(){
		    search(current);
		  });
	};

    function search(current){
        $.ajax({
            url: $('search_filter_url').val(),
            type: 'GET',
            data: current.searchFilterParams(),
            beforeSend: function(){
              $('.pitch-loading img').toggle();
              disableAll();
            },
            success: function(data){
                $('#results').html(data['content']);
                IN.parse(document.getElementsByClassName('page-' + data['page'])[0]);
            },
            error: function(){
                $('#results').html(searchFilterError);
            },
            complete: function(){
              $('.pitch-loading img').toggle();
              enableAll();
            }
        });
    }

    function highlightButton(buttonContainer,current_button){
        $(buttonContainer).find($('button')).each(function(index,button){
            $(button).removeClass('btn-success');
            $(current_button).addClass('btn-success');
        });
    }

    function disableAll(){
       $('.actions').find($('button')).each(function(index,button){ 
        $(button).attr("disabled", "disabled");
       });
       $('#searchBox').attr("disabled", "disabled");
    }

    function enableAll(){
       $('.actions').find($('button')).each(function(index,button){ 
        $(button).removeAttr("disabled");
       });
       $('#searchBox').removeAttr("disabled");
    }

    this.loading = function($button){
        var $lastButton = $('.button-container button').last();
        var $firstButton = $('.button-container button').first();
        
        if('likes' == $button.val()){
            $firstButton.text($firstButton.attr('data-loading-text'));
            $firstButton.attr('class', 'btn-success');
            $lastButton.attr('class', 'btn');
        }else{
            $lastButton.text($lastButton.attr('data-loading-text'));
            $lastButton.attr('class', 'btn-success');
            $firstButton.attr('class', 'btn');
        }
    };

    this.reset = function($button){
        if('likes' == $button.val()){
            var $firstButton = $('.button-container button').first();
            $firstButton.text($firstButton.attr('data-reset-text'));
        }else{
            var $lastButton = $('.button-container button').last();
            $lastButton.text($lastButton.attr('data-reset-text'));
        }
    };
}