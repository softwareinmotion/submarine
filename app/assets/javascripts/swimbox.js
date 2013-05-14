/*
	swimbox v1.25
	author: ldierolf
	copyrights softwareinmotion GmbH
*/
SWIMBOX = {
	init: function(){
		$('a.swimbox').on('click', SWIMBOX.detect);
	},
	detect: function(event){
		var url, background, container, close, image, image_source;
		url = $(event.currentTarget).attr('href');
		background = $('<div/>', {id: 'swimbox_bg'});
		container	= $('<div/>', {id: 'swimbox_container'});
		image = $('<div/>', {id: 'swimbox_image'});
		image_source = $('<img>', {src: url, 'class': 'img-rounded'});
		container.append(image);
		image.append(image_source);

		$('body').append(background);
		$('body').append(container);
		image_source.load(function() {SWIMBOX.build(image_source)});
		return false;
	},
	build: function(image_source){
		var pos_x, pos_y, image_height, image_width, window_height, window_width, scale_width, scale_height, scale_max, scale_factor, pYO;
		image_width = $(image_source).width();
		image_height = $(image_source).height();
		window_width = window.innerWidth;
		window_height = window.innerHeight;
		pYO = window.pageYOffset;

		scale_factor = 0.8;

		scale_height = image_height / window_height;
		scale_width = image_width / window_width;
		scale_max = Math.max(scale_height, scale_width);

		if(scale_max > scale_factor){
			image_height = (scale_factor * image_height) / scale_max;
			image_width = (scale_factor * image_width) / scale_max;
		}

		pos_x = ((window_width - image_width) / 2) - 10;
		pos_y = (((window_height - image_height) /2) -10)+ pYO;

		$('#swimbox_bg').css('top', pYO);
		$('#swimbox_image > img').css('width', image_width);
		$('#swimbox_image > img').css('height', image_height);
		$('#swimbox_container').css('width', image_width + 10);
		$('#swimbox_container').css('height', image_height + 10);
		$('#swimbox_container').css('top', pos_y);
		$('#swimbox_container').css('left', pos_x);
		$('body').css('overflow', 'hidden');

		$('#swimbox_bg').on('click', SWIMBOX.close_handler);
		$(image_source).on('click', SWIMBOX.close_handler);
	},
	close_handler: function(){
		$('#swimbox_container').remove();
		$('#swimbox_bg').remove();
		$('body').css('overflow', 'visible');
	}
};