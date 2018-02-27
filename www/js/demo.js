jQuery(function($) {

	// QWERTY Text Input
	// The bottom of this file is where the autocomplete extension is added
	// ********************
	$('#text').keyboard({ layout: 'qwerty' });

	$('.version').html( '(v' + $('#text').getkeyboard().version + ')' );

	// Contenteditable
	// ********************
	$.keyboard.keyaction.undo = function (base) {
		base.execCommand('undo');
		return false;
	};
	$.keyboard.keyaction.redo = function (base) {
		base.execCommand('redo');
		return false;
	};

	$('#contenteditable').keyboard({
		usePreview: false,
		useCombos: false,
		autoAccept: true,
		layout: 'custom',
		customLayout: {
			'normal': [
				'` 1 2 3 4 5 6 7 8 9 0 - = {del} {b}',
				'{tab} q w e r t y u i o p [ ] \\',
				'a s d f g h j k l ; \' {enter}',
				'{shift} z x c v b n m , . / {shift}',
				'{accept} {space} {left} {right} {undo:Undo} {redo:Redo}'
			],
			'shift': [
				'~ ! @ # $ % ^ & * ( ) _ + {del} {b}',
				'{tab} Q W E R T Y U I O P { } |',
				'A S D F G H J K L : " {enter}',
				'{shift} Z X C V B N M < > ? {shift}',
				'{accept} {space} {left} {right} {undo:Undo} {redo:Redo}'
			]
		},
		display: {
			del: '\u2326:Delete',
			redo: '↻',
			undo: '↺'
		}
	});

	// International Text Area
	// ********************
	$('#inter').keyboard({
		layout: 'international',
		css: {
			// input & preview
			// "label-default" for a darker background
			// "light" for white text
			input: 'form-control input-sm dark',
			// keyboard container
			container: 'center-block well',
			// default state
			buttonDefault: 'btn btn-default',
			// hovered button
			buttonHover: 'btn-primary',
			// Action keys (e.g. Accept, Cancel, Tab, etc);
			// this replaces "actionClass" option
			buttonAction: 'active',
			// used when disabling the decimal button {dec}
			// when a decimal exists in the input area
			buttonDisabled: 'disabled'
		}
	});

	// Console showing callback messages
	// ********************
	$('.ui-keyboard-input').bind('visible hidden beforeClose accepted canceled restricted', function(e, keyboard, el, status){
		var c = $('#console'),
			focused = false,
			val = keyboard.isContentEditable ? el.textContent : el.value,
			t = '<li><span class="keyboard">' + $(el).parent().find('h2 .tooltip-tipsy').text() + '</span>';
			switch (e.type){
				case 'visible'  : t += ' keyboard is <span class="event">visible</span>'; focused = true; break;
				case 'hidden'   : t += ' keyboard is now <span class="event">hidden</span>'; break;
				case 'accepted' : t += ' content "<span class="content">' + val + '</span>" was <span class="event">accepted</span>' + ($(el).is('[type=password]') ? ', yeah... not so secure :(' : ''); break;
				case 'canceled' : t += ' content was <span class="event ignored">ignored</span>'; break;
				case 'restricted'  : t += ' The "' + String.fromCharCode(e.keyCode) + '" key is <span class="event ignored">restricted</span>!'; focused = true; break;
				case 'beforeClose' : t += ' keyboard is about to <span class="event">close</span>, contents were <span class="event ' + (status ? 'accepted">accepted' : 'ignored">ignored') + '</span>'; break;
			}
		t += '</li>';
		c.append(t);
		if (c.find('li').length > 3) { c.find('li').eq(0).remove(); }
		// demo stuff only
		keyboard.$el.closest('.block').toggleClass('focused', focused);
	});

	// Show code
	// ********************
	$('h2 span').click(function(){
		var orig = 'Click, then scroll down to see this code',
			active = 'Scroll down to see the code for this example',
			t = '<h3>' + $(this).parent().text() + ' Code</h3>' + $(this).closest('.block').find('.code').html();
		// add indicator & update tooltips
		$('h2 span')
			.attr({ title : orig, 'original-title': orig })
			.parent()
			.filter('.active')
			.removeClass('active');
		$(this)
			.attr({ title : active, 'original-title': active })
			// hide, then show the tooltip to force updating & realignment
			.tipsy('hide')
			.tipsy('show')
			.parent().addClass('active');
		$('#showcode').html(t).show();
	});

	// add tooltips
	// ********************
	$('.tooltip-tipsy').tipsy({ gravity: 's' });
	$('.navbar [title]').tipsy({ gravity: 'n' });

// ********************
// Extension demos
// ********************

	// Set up typing simulator extension on ALL keyboards
	$('.ui-keyboard-input').addTyping();

	// simulate typing into the keyboard
	// \t or {t} = tab, \b or {b} = backspace, \r or \n or {e} = enter
	// added {l} = caret left, {r} = caret right & {d} = delete
	$('#inter-type').click(function(){
		$('#inter').getkeyboard().reveal().typeIn("{t}Hal{l}{l}{d}e{r}{r}l'o{b}o {e}{t}World", 500);
		return false;
	});
	$('#meta-type').click(function(){
		var meta = $('#meta').getkeyboard();
		meta.reveal().typeIn('aBcD1112389\u0411\u2648\u2649', 700, function(){ meta.accept(); alert('all done!'); });
		return false;
	});

});
