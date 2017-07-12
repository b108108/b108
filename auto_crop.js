var Demo = (function() {

	function output(node) {
		var existing = $('#result .croppie-result');
		if (existing.length > 0) {
			existing[0].parentNode.replaceChild(node, existing[0]);
		}
		else {
			$('#result')[0].appendChild(node);
		}
	}

	function popupResult(result) {
		var html;
		if (result.html) {
			html = result.html;
		}
		if (result.src) {
			html = '<img src="' + result.src + '" />';
		}
		swal({
			title: '',
			html: true,
			text: html,
			allowOutsideClick: true
		});
		setTimeout(function(){
			$('.sweet-alert').css('margin', function() {
				var top = -1 * ($(this).height() / 2),
					left = -1 * ($(this).width() / 2);

				return top + 'px 0 0 ' + left + 'px';
			});
		}, 1);
	}

	function demoUpload() {
		var $w = $('.upload-width'),
			$h = $('.upload-height'),
			w = parseInt($w.val(), 10),
			h = parseInt($h.val(), 10),
			size = 'viewport';
		
		//  create new object
		var vEl = document.getElementById('upload-demo'),
		vanilla = new Croppie(vEl, {
		// set crop size
        viewport: {
			width: w,
			height: h,
			type: 'square'
		},
		// set window size
		boundary: { width: 250, height: 250 },
		showZoomer: true,
		enableExif: true,
		enableOrientation: true
		});
	
		// set update view
		vEl.addEventListener('update', function (ev) {
			console.log('upload update', ev);
		});
		
		//rotate view left-right
		$('.upload-rotate').on('click', function(ev) {
			vanilla.rotate(parseInt($(this).data('deg')));
		});
	
		// open image file
		function readFile(input) {
 			if (input.files && input.files[0]) {
	            var reader = new FileReader();
	            
	            reader.onload = function (e) {
					$('.upload-demo').addClass('ready');
	            	vanilla.bind({
	                    url: e.target.result,
	                    orientation: 0,			
	                    zoom: 0
	                });
	            }
	            reader.readAsDataURL(input.files[0]);
	        }
	        else {
		        swal("Sorry - you're browser doesn't support the FileReader API");
		    }
		}

		// click upload button
		$('#upload').on('change', function () { readFile(this); });
		
		// save crop result with the specified size
		$('.upload-result').on('click', function (ev) {
			//get size crop from input field
			w = parseInt($w.val(), 10),
			h = parseInt($h.val(), 10),
			size = 'viewport';
			if (w || h) {
				size = { width: w, height: h };
			}
			vanilla.result({
				type: 'canvas',
				size: size
			}).then(function (resp) {
				popupResult({
					src: resp
				});
			});
		});
	}

	function init() {
		demoUpload();
	}

	return {
		init: init
	};
})();
