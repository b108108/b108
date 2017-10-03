$(document).ready(function(){
	//filters btn
	$('.icon-filter').click(function(e){
		e.preventDefault();
		$('.app').toggleClass('filters-open');
		$('.filters-wrapper').click(function(){
			$('.app').removeClass('filters-open');
		})
	})
	// filters-tabs
	$('.filters__titles__item').click(function(e){
		e.preventDefault();
		$('.filters__titles__item').removeClass('filters__titles__item--active');
		$(this).addClass('filters__titles__item--active');
		var data = $(this).attr('href');
		$('.filters__content--active').removeClass('filters__content--active');
		$('#'+data).addClass('filters__content--active');
		console.log(data);
	})

	$('#map-search').focusin(function(){
		$('.search-results').show();
	});
	$('#map-search').focusout(function(){
		$('.search-results').hide();
	});

	$('.minus').click(function () {
	 var $input = $(this).parent().find('.js-value');
	 var count = parseInt($input.text()) - 1;
	 count = count < 1 ? 1 : count;
	 $input.text(count);
	 return false;
	});

	$('.plus').click(function () {
	 var $input = $(this).parent().find('.js-value');
	 $input.text(parseInt($input.text()) + 1);
	 return false;
	});

	// $('.type-change').focusin(function(){
	// 	$(this).closest('.page-login').addClass('active-keyboard');
	// });
	// $('.type-change').focusout(function(){
	// 	$(this).closest('.page-login').removeClass('active-keyboard');
	// })
	
	// slider
	var hwSlideSpeed = 1200;
	var hwTimeOut = 5000;
	var hwNeedLinks = true;
	$(document).ready(function(e) {
	    $('.js-slider-item').css(
	        {"position" : "absolute",
	         "top":'0', "left": '0'}).hide().eq(0).show();
	    var slideNum = 0;
	    var slideTime;
	    slideCount = $(".js-slider .js-slider-item").size();
	    var animSlide = function(arrow){
	        clearTimeout(slideTime);
	        $('.js-slider-item').eq(slideNum).fadeOut(hwSlideSpeed);
	        if(arrow == "next"){
	            if(slideNum == (slideCount-1)){slideNum=0;}
	            else{slideNum++}
	            }
	        else if(arrow == "prew")
	        {
	            if(slideNum == 0){slideNum=slideCount-1;}
	            else{slideNum-=1}
	        }
	        else{
	            slideNum = arrow;
	            }
	        $('.js-slider-item').eq(slideNum).fadeIn(hwSlideSpeed, rotator);
	        $(".control-slide.active").removeClass("active");
	        $('.control-slide').eq(slideNum).addClass('active');
	        }
	if(hwNeedLinks){
	var $linkArrow = $('<a id="prewbutton" href="#"></a><a id="nextbutton" href="#"></a>')
	    .prependTo('.product-slider');      
	    $('#nextbutton').click(function(){
	        animSlide("next");
	 
	        })
	    $('#prewbutton').click(function(){
	        animSlide("prew");
	        })
	}
	    var $adderSpan = '';
	    $('.js-slider-item').each(function(index) {
	            $adderSpan += '<span class = "control-slide">' + index + '</span>';
	        });
	    $('<div class ="sli-links">' + $adderSpan +'</div>').appendTo('.product-top');
	    $(".control-slide:first").addClass("active");
	     
	    $('.control-slide').click(function(){
	    var goToNum = parseFloat($(this).text());
	    animSlide(goToNum);
	    });
	    var pause = false;
	    var rotator = function(){
	    if(!pause){slideTime = setTimeout(function(){animSlide('next')}, hwTimeOut);}
	            }
	    rotator();
	});
})

// $(function () {
//  if (!(/iPad|iPhone|iPod/.test(navigator.userAgent))) return
//  $(document.head).append(
//     '<st yle>*{cursor:pointer;-webkit-tap-highlight-color:rgba(0,0,0,0)}</style>'
//  )
//  $(window).on('gesturestart touchmove', function (evt) {
//    if (evt.originalEvent.scale !== 1) {
//      evt.originalEvent.preventDefault()
//      document.body.style.transform = 'scale(1)'
//    }
//  })
// })