/*  Facebox for Prototype, version 2.0
 *  By Robert Gaal - http://wakoopa.com 
 *
 *  Heavily based on Facebox by Chris Wanstrath - http://famspam.com/facebox
 *  First ported to Prototype by Phil Burrows - http://blog.philburrows.com
 *
 *  Licensed under the MIT:
 *  http://www.opensource.org/licenses/mit-license.php
 *
 *  Need help?  Join the Google Groups mailing list:
 *  http://groups.google.com/group/facebox/
 *
 *  Dependencies:   prototype & script.aculo.us + images & CSS files from original facebox
 *  Usage:          Append 'rel="facebox"' to an element to call it inside a so-called facebox
 *
 *--------------------------------------------------------------------------*/


var Facebox = Class.create({
	initialize	: function(extra_set){
		this.settings = {
			loading_image	: '/facebox/loading.gif',
			close_image		: '/facebox/closelabel.gif',
			image_types		: new RegExp('\.' + ['png', 'jpg', 'jpeg', 'gif'].join('|') + '$', 'i'),
			inited				: true,	
			facebox_html	: '\
	  <div id="facebox" style="display:none;"> \
	    <div class="popup"> \
	      <table id="facebox_table"> \
	        <tbody> \
	          <tr> \
	            <td class="tl"/><td class="b"/><td class="tr"/> \
	          </tr> \
	          <tr> \
	            <td class="b"/> \
	            <td class="body"> \
	              <div class="content"> \
	              </div> \
	              <div class="footer"> \
	                <a href="#" class="close"> \
	                  <img src="/facebox/closelabel.gif" title="close" class="close_image" /> \
	                </a> \
	              </div> \
	            </td> \
	            <td class="b"/> \
	          </tr> \
	          <tr> \
	            <td class="bl"/><td class="b"/><td class="br"/> \
	          </tr> \
	        </tbody> \
	      </table> \
	    </div> \
	  </div>'
		};
		if (extra_set) Object.extend(this.settings, extra_set);
		$(document.body).insert({bottom: this.settings.facebox_html});
		
		this.preload = [ new Image(), new Image() ];
		this.preload[0].src = this.settings.close_image;
		this.preload[1].src = this.settings.loading_image;
		
		f = this;
		$$('#facebox .b:first, #facebox .bl, #facebox .br, #facebox .tl, #facebox .tr').each(function(elem){
			f.preload.push(new Image());
			f.preload.slice(-1).src = elem.getStyle('background-image').replace(/url\((.+)\)/, '$1');
		});
		
		this.facebox = $('facebox');
    this.keyPressListener = this.watchKeyPress.bindAsEventListener(this);
		
		this.watchClickEvents();
		fb = this;
		Event.observe($$('#facebox .close').first(), 'click', function(e){
			Event.stop(e);
			fb.close()
		});
		Event.observe($$('#facebox .close_image').first(), 'click', function(e){
			Event.stop(e);
			fb.close()
		});
	},
	
  watchKeyPress : function(e){
    // Close if espace is pressed or if there's a click outside of the facebox
    if (e.keyCode == 27 || !Event.element(e).descendantOf(this.facebox)) this.close();
  },
	
	watchClickEvents	: function(e){
		var f = this;
		$$('a[rel=facebox]').each(function(elem,i){
			Event.observe(elem, 'click', function(e){
				Event.stop(e);
				f.click_handler(elem, e);
			});
		});
	},
	
	loading	: function() {
		if ($$('#facebox .loading').length == 1) return true;
		
		contentWrapper = $$('#facebox .content').first();
		contentWrapper.childElements().each(function(elem, i){
			elem.remove();
		});
		contentWrapper.insert({bottom: '<div class="loading"><img src="'+this.settings.loading_image+'"/></div>'});
		
		var pageScroll = document.viewport.getScrollOffsets();
		this.facebox.setStyle({
			'top': pageScroll.top + (document.viewport.getHeight() / 5) + 'px',
			'left': document.viewport.getWidth() / 2 - (this.facebox.getWidth() / 2) + 'px'
		});
		
    Event.observe(document, 'keypress', this.keyPressListener);
    Event.observe(document, 'click', this.keyPressListener);
	},
	
	reveal	: function(data, klass){
		this.loading();
		load = $$('#facebox .loading').first();
		if(load) load.remove();

    this.show_overlay();
		
		contentWrapper = $$('#facebox .content').first();
		if (klass) contentWrapper.addClassName(klass);
		contentWrapper.insert({bottom: data});
		
    $$('#facebox .body').first().childElements().each(function(elem,i){
     elem.show();
    });
    		
		if(!this.facebox.visible()) new Effect.Appear(this.facebox, {duration: .3});
		this.facebox.setStyle({
			'left': document.viewport.getWidth() / 2 - (this.facebox.getWidth() / 2) + 'px'
		});
		
    Event.observe(document, 'keypress', this.keyPressListener);
    Event.observe(document, 'click', this.keyPressListener);
	},
	
	close		: function(){
    this.hide_overlay();
    new Effect.Fade('facebox', {duration: 0.25});
	},
	
	click_handler	: function(elem, e){
	  this.loading();
		Event.stop(e);
		
		// support for rel="facebox[.inline_popup]" syntax, to add a class
		var klass = elem.rel.match(/facebox\[\.(\w+)\]/);
		if (klass) klass = klass[1];
		
		new Effect.Appear(this.facebox, {duration: .3});
		
		if (elem.href.match(/#/)){
			var url			= window.location.href.split('#')[0];
			var target	= elem.href.replace(url+'#','');
			// var data			= $$(target).first();
			var d			  = $(target);
			// create a new element so as to not delete the original on close()
			var data = new Element(d.tagName);
			data.innerHTML = d.innerHTML;
			this.reveal(data, klass);
		} else if (elem.href.match(this.settings.image_types)) {
			var image = new Image();
			fb = this;
			image.onload = function() {
				fb.reveal('<div class="image"><img src="' + image.src + '" /></div>', klass)
			}
			image.src = elem.href;
		} else {
			var fb  = this;
			var url = elem.href;
			new Ajax.Request(url, {
				method		: 'get',
				onFailure	: function(transport){
					fb.reveal(transport.responseText, klass);
				},
				onSuccess	: function(transport){
					fb.reveal(transport.responseText, klass);
				}
			});
			
		}
	},

  show_overlay: function() {
    if (!$("facebox_overlay")) {
      new Insertion.Top(document.body, '<div id="facebox_overlay" style="display:none;"></div>');
    }
    this.set_overlay_size();
    // this.hide_selects();
    new Effect.Appear("facebox_overlay", { duration: 0.3 });
  },

  hide_overlay: function() {
    // this.show_selects();
    new Effect.Fade("facebox_overlay", { duration: 0.3 });
  },

  set_overlay_size: function() {
    if (window.innerHeight && window.scrollMaxY) {
      yScroll = window.innerHeight + window.scrollMaxY;
    } else if (document.body.scrollHeight > document.body.offsetHeight) {
      yScroll = document.body.scrollHeight;
    } else {
      yScroll = document.body.offsetHeight;
    }
    $("facebox_overlay").style['height'] = yScroll + "px";
  },

  hide_selects: function() {
    selects = document.getElementsByTagName("select");
    for (i = 0;  i < selects.length;  i++) {
      selects[i].style.visibility = "hidden";
    }
  },

  show_selects: function() {
    selects = document.getElementsByTagName("select");
    for (i = 0;  i < selects.length;  i++) {
      selects[i].style.visibility = "visible";
    }
  }
});

var facebox;
document.observe('dom:loaded', function(){
	facebox = new Facebox();
});