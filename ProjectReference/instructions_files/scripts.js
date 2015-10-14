var patternOptions = [	
	'buseca-1',
	'h-lines-bold',
	'h-lines-medium',
	'h-lines-light',
	'o-lines-bold',
	'o-lines-medium',
	'o-lines-light',
	'cross-bold',
	'cross-medium',
	'cross-light',
	'cross-bold-thin',
	'cross-medium-thin',
	'cross-light-thin'
];

$(document).ready(function() {

	var $bgElem = $('.theme-bg'),
		randomColour = Please.make_color({saturation:0.25}),
		randomScale = Math.floor(Math.random() * 50) + 20;
		randomPattern = patternOptions[Math.floor(Math.random() * patternOptions.length)];

	$bgElem
		.css('background-color', randomColour)
		.addClass(randomPattern);

	$('<style>.theme-bg:after{background-size:'+ randomScale + 'px;}</style>').appendTo('head');
});