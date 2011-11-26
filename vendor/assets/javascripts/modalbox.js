/*
ModalBox - The pop-up window thingie with AJAX, based on prototype and script.aculo.us.

Copyright Andrey Okonetchnikov (andrej.okonetschnikow@gmail.com), 2006-2007
All rights reserved.

VERSION 1.6.1
Last Modified: 01/11/2010
*/

if (Object.isUndefined(Prototype.Browser.IE6)) {
	Prototype.Browser.IE6 = (navigator.appName.indexOf("Microsoft Internet Explorer") != -1 && navigator.appVersion.indexOf("MSIE 6.0") != -1 && !window.XMLHttpRequest);
}

if (!window.Modalbox)
	var Modalbox = {};

Modalbox.Methods = {
	overrideAlert: false, // Override standard browser alert message with ModalBox
	focusableElements: [],
	currFocused: 0,
	initialized: false, // Modalbox is visible
	active: true, // Modalbox is visible and active
	options: {
		title: "ModalBox Window", // Title of the ModalBox window
		overlayClose: true, // Close modal box by clicking on overlay
		width: 500, // Default width in px
		height: 90, // Default height in px
		overlayOpacity: 0.5, // Default overlay opacity
		overlayDuration: 0.1, // Default overlay fade in/out duration in seconds
		slideDownDuration: 0.25, // Default Modalbox appear slide down effect in seconds
		slideUpDuration: 0.25, // Default Modalbox hiding slide up effect in seconds
		resizeDuration: 0.1, // Default resize duration seconds
		inactiveFade: true, // Fades MB window on inactive state
		transitions: true, // Toggles transition effects. Transitions are enabled by default
		loadingString: "Please wait. Loading...", // Default loading string message
		closeString: "Close window", // Default title attribute for close window link
		closeValue: "&times;", // Default string for close link in the header
		params: {},
		method: "get", // Default Ajax request method
		autoFocusing: true, // Toggles auto-focusing for form elements. Disable for long text pages.
		aspnet: false // Should be true when using with ASP.NET controls. When true Modalbox window will be injected into the first form element.
	},
	_options: {},

	setOptions: function(options) {
		Object.extend(this.options, options || {});
	},

	_init: function(options) {
		// Setting up original options with default options
		Object.extend(this._options, this.options);
		this.setOptions(options);

		// Creating the overlay
		this.MBoverlay = new Element("div", {id: "MB_overlay", style: "opacity: 0"});

		// Creating the modal window
		this.MBwindow = new Element("div", {id: "MB_window", style: "display: none"}).update(
			this.MBframe = new Element("div", {id: "MB_frame"}).update(
				this.MBheader = new Element("div", {id: "MB_header"}).update(
					this.MBcaption = new Element("div", {id: "MB_caption"})
				)
			)
		);
		this.MBclose = new Element("a", {id: "MB_close", title: this.options.closeString, href: "#"}).update("<span>" + this.options.closeValue + "</span>");
		this.MBheader.insert({'bottom':this.MBclose});

		this.MBcontent = new Element("div", {id: "MB_content"}).update(
			this.MBloading = new Element("div", {id: "MB_loading"}).update(this.options.loadingString)
		);
		this.MBframe.insert({'bottom':this.MBcontent});

		// Inserting into DOM. If parameter set and form element have been found will inject into it. Otherwise will inject into body as topmost element.
		// Be sure to set padding and marging to null via CSS for both body and (in case of asp.net) form elements.
		var injectToEl = this.options.aspnet ? $(document.body).down('form') : $(document.body);
		injectToEl.insert({'top':this.MBwindow});
		injectToEl.insert({'top':this.MBoverlay});

		// Initial scrolling position of the window. To be used for remove scrolling effect during ModalBox appearing
		this.initScrollX = window.pageXOffset || document.body.scrollLeft || document.documentElement.scrollLeft;
		this.initScrollY = window.pageYOffset || document.body.scrollTop || document.documentElement.scrollTop;

		//Adding event observers
		this.hideObserver = this._hide.bindAsEventListener(this);
		this.kbdObserver = this._kbdHandler.bindAsEventListener(this);
		this.resizeObserver = this._setWidthAndPosition.bindAsEventListener(this);
		this._initObservers();

		this.initialized = true; // Mark as initialized
	},

	show: function(content, options) {
		if (!this.initialized) this._init(options); // Check if MB is already initialized

		this.content = content;
		this.setOptions(options);

		if (this.options.title) { // Updating title of the MB
			this.MBcaption.update(this.options.title);
		} else { // If title isn't given, the header will not displayed
			this.MBheader.hide();
			this.MBcaption.hide();
		}

		if (this.MBwindow.style.display == "none") { // First MB appearing
			this._appear();
			this.event("onShow"); // Passing onShow callback
		} else { // If MB already on the screen, update it
			this._update();
			this.event("onUpdate"); // Passing onUpdate callback
		}
	},

	hide: function(options) { // External hide method to use from external HTML and JS
		if(this.initialized) {
			// Reading for options/callbacks except if event given as a parameter
			if (options && !Object.isFunction(options.element))
				Object.extend(this.options, options);
			this.event("beforeHide"); // Passing beforeHide callback
			if (this.options.transitions) {
				Effect.SlideUp(this.MBwindow, { duration: this.options.slideUpDuration, transition: Effect.Transitions.sinoidal, afterFinish: this._deinit.bind(this) });
			} else {
				this.MBwindow.hide();
				this._deinit();
			}
		} else {
			throw("Modalbox is not initialized.");
		}
	},

	_hide: function(event) { // Internal hide method to use with overlay and close link
		event.stop(); // Stop event propagation for link elements
		// When clicked on overlay we'll check the option and in case of overlayClose == false we'll break hiding execution [Fix for #139]
		if (event.element().id == 'MB_overlay' && !this.options.overlayClose) return false;
		this.hide();
	},

	alert: function(message){
		var html = '<div class="MB_alert"><p>' + message + '</p><input type="button" onclick="Modalbox.hide()" value="OK" /></div>';
		Modalbox.show(html, {title: 'Alert: ' + document.title, width: 300});
	},

	_appear: function() { // First appearing of MB
		if (Prototype.Browser.IE6) { // Preparing IE 6 for showing modalbox
			window.scrollTo(0,0);
			this._prepareIEHtml("100%", "hidden");
			this._prepareIESelects("hidden");
		}
		this._setSize();
		this._setPosition();
		if(this.options.transitions) {
			this.MBoverlay.setOpacity(0);
			new Effect.Fade(this.MBoverlay, {
				from: 0,
				to: this.options.overlayOpacity,
				duration: this.options.overlayDuration,
				afterFinish: (function() {
					new Effect.SlideDown(this.MBwindow, {
						duration: this.options.slideDownDuration,
						transition: Effect.Transitions.sinoidal,
						afterFinish: (function() {
							this._setPosition();
							this.loadContent();
						}).bind(this)
					});
				}).bind(this)
			});
		} else {
			this.MBoverlay.setOpacity(this.options.overlayOpacity);
			this.MBwindow.show();
			this._setPosition();
			this.loadContent();
		}
		Event.observe(window, "resize", this.resizeObserver);
	},

	_update: function() { // Updating MB in case of wizards
		this.MBcontent.update($(this.MBloading).update(this.options.loadingString));
		this.loadContent();
	},

	resizeTo: function(newWidth, newHeight, options) { // Change size of MB without content reloading
		var o = this.MBoverlay.getDimensions();
		var newStyle = {width: newWidth + "px", height: newHeight + "px", left: (o.width - newWidth)/2 + "px"};
		this.options.width = newWidth;
		if (options) this.setOptions(options); // Passing callbacks
		if (this.options.transitions) {
			new Effect.Morph(this.MBwindow, {
				style: newStyle,
				duration: this.options.resizeDuration,
				beforeStart: function(fx){
					fx.element.setStyle({overflow: "hidden"}); // Fix for MSIE 6 to resize correctly
				},
				afterFinish: (function(fx) {
					fx.element.setStyle({overflow: "visible"});
					this.event("_afterResize"); // Passing internal callback
					this.event("afterResize"); // Passing callback
				}).bind(this)
			});
		} else {
			this.MBwindow.setStyle(newStyle);
			(function() {
				this.event("_afterResize"); // Passing internal callback
				this.event("afterResize"); // Passing callback
			}).bind(this).defer();
		}
	},

	resize: function(byWidth, byHeight, options) { // Change size of MB without loading content
		var w = this.MBwindow.getDimensions(), hHeight = this.MBheader.getHeight(), cHeight = this.MBcontent.getHeight();
		this.resizeTo((w.width + byWidth), Math.max(hHeight + cHeight, w.height + byHeight), options);
	},

	resizeToContent: function(options){
		// Resizes the modalbox window to the actual content height.
		// This might be useful to resize modalbox after some content modifications which were changed content height.

		var byHeight = this.options.height - this.MBwindow.getHeight();
		if (byHeight != 0) {
			this.resize(0, byHeight, options);
		}
	},

	resizeToInclude: function(element, options){
		// Resizes the modalbox window to the cumulative height of element. Calculations are using CSS properties for margins and border.
		// This method might be useful to resize modalbox before including or updating content.

		element = $(element);
		var styles = ['margin-top','margin-bottom','border-top-width','border-bottom-width'];
		var elHeight = styles.inject(element.getHeight(), function(acc, n) {
			var x = parseInt(element.getStyle(n), 10);
			acc += (isNaN(x) ? 0 : x);
			return acc;
		});
		if (elHeight > 0) {
			Modalbox.resize(0, elHeight, options);
		}
	},

	loadContent: function() {
		if (this.event("beforeLoad")) { // If callback returned false, skip loading of the content
			if (typeof this.content == 'string') {
				var htmlRegExp = new RegExp(/<\/?[^>]+>/gi), evalScript = function(script) {
					return eval(script.replace("<!--", "").replace("// -->", ""));
				};
				if (htmlRegExp.test(this.content)) { // Plain HTML given as a parameter
					this._insertContent(this.content.stripScripts(), (function() {
						this.content.extractScripts().map(evalScript, window);
					}).bind(this));
				} else { // URL given as a parameter. We'll request it via Ajax
					new Ajax.Request(this.content, {
						method: this.options.method.toLowerCase(),
						parameters: this.options.params,
						onSuccess: (function(transport) {
							var response = new String(transport.responseText);
							this._insertContent(transport.responseText.stripScripts(), function(){
								response.extractScripts().map(evalScript, window);
							});
						}).bind(this),
						onException: function(instance, exception){
							Modalbox.hide();
							throw('Modalbox Loading Error: ' + exception);
						}
					});
				}
			} else if (typeof this.content == 'object') { // HTML Object is given
				this._insertContent(this.content);
			} else {
				this.hide();
				throw('Modalbox Parameters Error: Please specify correct URL or HTML element (plain HTML or object)');
			}
		}
	},

	_insertContent: function(content, callback) {
		this.MBcontent.hide().update();

		if (typeof content == 'string') { // Plain HTML is given
			this.MBcontent.insert(new Element("div", { style: "display: none" }).update(content)).down().show();
		} else if (typeof content == 'object') { // HTML Object is given
			var _htmlObj = content.cloneNode(true); // If node already a part of DOM we'll clone it
			// If cloneable element has ID attribute defined, modifying it to prevent duplicates
			if (content.id) content.id = "MB_" + content.id;
			// Add prefix for IDs on all elements inside the DOM node
			$(content).select('*[id]').each(function(el) { el.id = "MB_" + el.id; });
			this.MBcontent.insert(_htmlObj).down().show();
			if (Prototype.Browser.IE6) { // Toggle back visibility for hidden selects in IE
				this._prepareIESelects("", "#MB_content ");
			}
		}

		// Prepare and resize modal box for content
		if (this.options.height == this._options.height) {
			this.resizeTo(this.options.width, this.MBheader.getHeight() + this.MBcontent.getHeight(), {
				afterResize: (function() {
					this._putContent.bind(this, callback).defer(); // MSIE fix
				}).bind(this)
			});
		} else { // Height is defined. Creating a scrollable window
			this._setSize();
			this.MBcontent.setStyle({
				overflow: 'auto',
				height: this.options.height - this.MBheader.getHeight() - 13 + 'px'
			});
			this._putContent.bind(this, callback).defer(); // MSIE fix
		}
	},

	_putContent: function(callback) {
		this.MBcontent.show();
		this._findFocusableElements();
		this._setFocus(); // Setting focus on first 'focusable' element in content (input, select, textarea, link or button)
		if (Object.isFunction(callback))
			callback(); // Executing internal JS from loaded content
		this.event("afterLoad"); // Passing callback
	},

	activate: function(options) {
		this.setOptions(options);
		this.active = true;
		if (this.options.overlayClose)
			this.MBoverlay.observe("click", this.hideObserver);
		this.MBclose.observe("click", this.hideObserver).show();
		if (this.options.transitions && this.options.inactiveFade)
			new Effect.Appear(this.MBwindow, {duration: this.options.slideUpDuration});
	},

	deactivate: function(options) {
		this.setOptions(options);
		this.active = false;
		if (this.options.overlayClose)
			this.MBoverlay.stopObserving("click", this.hideObserver);
		this.MBclose.stopObserving("click", this.hideObserver).hide();
		if (this.options.transitions && this.options.inactiveFade)
			new Effect.Fade(this.MBwindow, {duration: this.options.slideUpDuration, to: 0.75});
	},

	_initObservers: function() {
		this.MBclose.observe("click", this.hideObserver);
		if (this.options.overlayClose)
			this.MBoverlay.observe("click", this.hideObserver);
		// Gecko and Opera are moving focus a way too fast, all other browsers are okay with keydown
		var kbdEvent = (Prototype.Browser.Gecko || Prototype.Browser.Opera) ? "keypress" : "keydown";
		Event.observe(document, kbdEvent, this.kbdObserver);
	},

	_removeObservers: function() {
		this.MBclose.stopObserving("click", this.hideObserver);
		if (this.options.overlayClose)
			this.MBoverlay.stopObserving("click", this.hideObserver);
		var kbdEvent = (Prototype.Browser.Gecko || Prototype.Browser.Opera) ? "keypress" : "keydown";
		Event.stopObserving(document, kbdEvent, this.kbdObserver);
	},

	_setFocus: function() {
		// Setting focus to the first 'focusable' element which is one with tabindex = 1 or the first in the form loaded.
		if (this.options.autoFocusing === true && this.focusableElements.length > 0) {
			var firstEl = this.focusableElements.find(function (el){
				return el.tabIndex == 1;
			}) || this.focusableElements.first();
			this.currFocused = this.focusableElements.toArray().indexOf(firstEl);
			firstEl.focus(); // Focus on first focusable element except close button
		} else if (this.MBclose.visible()) {
			this.MBclose.focus(); // If no focusable elements exist focus on close button
		}
	},

	_findFocusableElements: function() { // Collect form elements or links from MB content
		if (this.options.autoFocusing === true) {
			// TODO maybe add :enabled to select and textarea elements
			this.MBcontent.select('input:not([type~=hidden]):enabled, select, textarea, button, a[href]').invoke('addClassName', 'MB_focusable');
			this.focusableElements = this.MBcontent.select('.MB_focusable');
		}
	},

	_kbdHandler: function(event) {
		var node = event.element();
		switch(event.keyCode) {
			case Event.KEY_TAB:
				event.stop();

				// Switching currFocused to the element which was focused by mouse instead of TAB-key. Fix for #134
				if (node != this.focusableElements[this.currFocused])
					this.currFocused = this.focusableElements.indexOf(node);

				if (!event.shiftKey) { // Focusing in direct order
					if(this.currFocused >= this.focusableElements.length - 1) {
						this.currFocused = 0;
					} else {
						this.currFocused++;
					}
				} else { // Shift key is pressed. Focusing in reverse order
					if(this.currFocused <= 0) {
						this.currFocused = this.focusableElements.length - 1;
					} else {
						this.currFocused--;
					}
				}
				this.focusableElements[this.currFocused].focus();
				break;
			case Event.KEY_ESC:
				if (this.active) this._hide(event);
				break;
			case 32:
				this._preventScroll(event);
				break;
			case 0: // For Gecko browsers compatibility
				if (event.which == 32) this._preventScroll(event);
				break;
			case Event.KEY_UP:
			case Event.KEY_DOWN:
			case Event.KEY_PAGEDOWN:
			case Event.KEY_PAGEUP:
			case Event.KEY_HOME:
			case Event.KEY_END:
				// Safari operates in slightly different way. This realization is still buggy in Safari.
				if (Prototype.Browser.WebKit && !["textarea", "select"].include(node.tagName.toLowerCase()))
					event.stop();
				else if ((node.tagName.toLowerCase() == "input" && ["submit", "button"].include(node.type)) || (node.tagName.toLowerCase() == "a"))
					event.stop();
				break;
		}
	},

	_preventScroll: function(event) { // Disabling scrolling by "space" key
		if (!["input", "textarea", "select", "button"].include(event.element().tagName.toLowerCase()))
			event.stop();
	},

	_deinit: function() {
		this._removeObservers();
		Event.stopObserving(window, "resize", this.resizeObserver);
		if (this.options.transitions) {
			Effect.toggle(this.MBoverlay, 'appear', {duration: this.options.overlayDuration, afterFinish: this._removeElements.bind(this) });
		} else {
			this.MBoverlay.hide();
			this._removeElements();
		}
		this.MBcontent.setStyle({overflow: '', height: ''});
	},

	_removeElements: function() {
		if (Prototype.Browser.Opera) { // Remove overlay after-effects in Opera
			window.scrollBy(0, 0);
		}
		this.MBoverlay.remove();
		this.MBwindow.remove();
		if (Prototype.Browser.IE6) {
			this._prepareIEHtml("", ""); // If set to auto MSIE will show horizontal scrolling
			this._prepareIESelects("");
			window.scrollTo(this.initScrollX, this.initScrollY);
		}

		// Replacing prefixes 'MB_' in IDs for the original content
		if (typeof this.content == 'object') {
			if(this.content.id && this.content.id.match(/MB_/)) {
				this.content.id = this.content.id.replace(/MB_/, "");
			}
			this.content.select('*[id]').each(function(el) { el.id = el.id.replace(/MB_/, ""); });
		}
		// Initialized will be set to false
		this.initialized = false;
		this.event("afterHide"); // Passing afterHide callback
		this.setOptions(this._options); // Settings options object into initial state
	},

	_setSize: function() { // Set size
		this.MBwindow.setStyle({width: this.options.width + "px", height: this.options.height + "px"});
	},

	_setPosition: function() {
		this.MBwindow.setStyle({left: ((this.MBoverlay.getWidth() - this.MBwindow.getWidth()) / 2 ) + "px"});
	},

	_setWidthAndPosition: function() {
		this.MBwindow.setStyle({
			width: this.options.width + "px",
			left: ((this.MBoverlay.getWidth() - this.options.width) / 2 ) + "px"
		});
	},

	_prepareIEHtml: function(height, overflow) { // IE requires width and height set to 100% and overflow hidden
		$$('html, body').invoke('setStyle', {width: height, height: height, overflow: overflow});
	},

	_prepareIESelects: function(overflow, prefix) { // Toggle visibility for select elements
		$$((prefix || "") + "select").invoke('setStyle', {'visibility': overflow});
	},

	event: function(eventName) {
		var r = true;
		if (this.options[eventName]) {
			var returnValue = this.options[eventName](); // Executing callback
			this.options[eventName] = null; // Removing callback after execution
			if (!Object.isUndefined(returnValue))
				r = returnValue;
		}
		Event.fire(document, 'Modalbox:' + eventName);
		return r;
	}
};

Object.extend(Modalbox, Modalbox.Methods);

if (Modalbox.overrideAlert) window.alert = Modalbox.alert;
