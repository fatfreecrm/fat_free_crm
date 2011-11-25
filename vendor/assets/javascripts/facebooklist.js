
/*
  Proto!MultiSelect
  Copyright: InteRiders <http://interiders.com/> - Distributed under MIT - Keep this message!
*/

// Added key contstant for COMMA watching happiness
Object.extend(Event, {
  KEY_COMMA: {code: 188, value:","},
  KEY_SPACE: {code: 32, value:" "}
});

var ResizableTextbox = Class.create({
  initialize: function(element, options) {
    var that = this;
    this.options = $H({
      min: 5,
      max: 500,
      step: 7
    });
    this.options.update(options);
    this.el = $(element);
    this.width = this.el.offsetWidth;
    this.el.observe(
      'keyup', function() {
        var newsize = that.options.get('step') * $F(this).length;
        if(newsize <= that.options.get('min')) newsize = that.width;
        if(! ($F(this).length == this.retrieveData('rt-value') || newsize <= that.options.min || newsize >= that.options.max))
          this.setStyle({'width': newsize});
      }).observe('keydown', function() {
        this.cacheData('rt-value', $F(this).length);
      }
    );
  }
});

var TextboxList = Class.create({
  initialize: function(element, options) {
    this.options = $H({/*
      onFocus: $empty,
      onBlur: $empty,
      onInputFocus: $empty,
      onInputBlur: $empty,
      onBoxFocus: $empty,
      onBoxBlur: $empty,
      onBoxDispose: $empty,*/
      resizable: {},
      className: 'bit',
      separator: Event.KEY_COMMA,
      tabindex: null,
      extrainputs: true,
      startinput: true,
      hideempty: true,
      newValues: false,
      newValueDelimiters: ['[',']'],
      spaceReplace: '',
      fetchFile: undefined,
      fetchMethod: 'get',
      results: 10,
      maxResults: 0, // 0 = set to default (which is 10 (see FacebookList class)),
      wordMatch: false,
      onEmptyInput: function(input){},
      onAdd: function(tag){},
      onDispose: function(tag){},
      caseSensitive: false,
      regexSearch: true
    });
    this.current_input = "";
    this.options.update(options);
    this.element = $(element).hide();
    this.bits = new Hash();
    this.events = new Hash();
    this.count = 0;
    this.current = false;
    this.maininput = this.createInput({className: 'maininput'});
    this.maininput.addClassName('maininput');
    this.holder = new Element('ul', {
      className: 'holder'
    }).insert(this.maininput);
    if(this.options.get('tabindex')) {
      this.maininput.down('input').writeAttribute('tabindex', this.options.get('tabindex'));
    }
    this.element.insert({'before':this.holder});
    this.holder.observe('click', function(event){
      event.stop();
      if(this.maininput != this.current) this.focus(this.maininput);
    }.bind(this));
    this.makeResizable(this.maininput);
    this.setEvents();
  },

  setEvents: function() {
    document.observe(Prototype.Browser.IE ? 'keydown' : 'keypress', function(e) {
      if(! this.current) return;
      if(this.current.retrieveData('type') == 'box' && e.keyCode == Event.KEY_BACKSPACE) e.stop();
    }.bind(this));

    document.observe(
      'keyup', function(e) {
        e.stop();
        if(! this.current) return;
        switch(e.keyCode){
          case Event.KEY_LEFT: return this.move('left');
          case Event.KEY_RIGHT: return this.move('right');
          case Event.KEY_DELETE:
          case Event.KEY_BACKSPACE: return this.moveDispose();
        }
      }.bind(this)).observe(
      'click', function() { document.fire('blur'); }.bindAsEventListener(this)
    );
  },

  update: function() {
    this.element.value = this.bits.values().join(this.options.get('separator').value);
    if (!this.current_input.blank()){
      this.element.value += (this.element.value.blank() ? "" : this.options.get('separator').value) + this.current_input;
    }
    return this;
  },

  add: function(text, html) {
    var id = this.id_base + '-' + this.count++;
    var el = this.createBox($pick(html, text), {'id': id, 'class': this.options.get('className'), 'newValue' : text.newValue ? 'true' : 'false'});
    (this.current || this.maininput).insert({'before':el});
    el.observe('click', function(e) {
      e.stop();
      this.focus(el);
    }.bind(this));
    this.bits.set(id, text.value);
    // Dynamic updating... why not?
    this.update();
    if(this.options.get('extrainputs') && (this.options.get('startinput') || el.previous())) this.addSmallInput(el,'before');
    this.options.get('onAdd')(text.value, el);
    return el;
  },

  addSmallInput: function(el, where) {
    var input = this.createInput({'class': 'smallinput'});
    el.insert({}[where] = input);
    input.cacheData('small', true);
    this.makeResizable(input);
    if(this.options.get('hideempty')) input.hide();
    return input;
  },

  dispose: function(el) {
    this.options.get('onDispose')(this.bits.get(el.id));
    this.bits.unset(el.id);
    // Dynamic updating... why not?
    this.update();
    if(el.previous() && el.previous().retrieveData('small')) el.previous().remove();
    if(this.current == el) this.focus(el.next());
    if(el.retrieveData('type') == 'box') el.onBoxDispose(this);
    el.remove();
    return this;
  },

  focus: function(el, nofocus) {
    if(! this.current) el.fire('focus');
    else if(this.current == el) return this;
    this.blur();
    el.addClassName(this.options.get('className') + '-' + el.retrieveData('type') + '-focus');
    if(el.retrieveData('small')) el.setStyle({'display': 'block'});
    if(el.retrieveData('type') == 'input') {
      el.onInputFocus(this);
      if(! nofocus) this.callEvent(el.retrieveData('input'), 'focus');
    }
    else el.fire('onBoxFocus');
    this.current = el;
    return this;
  },

  blur: function(noblur) {
    if(! this.current) return this;
    if(this.current.retrieveData('type') == 'input') {
      var input = this.current.retrieveData('input');
      if(! noblur) this.callEvent(input, 'blur');
      input.onInputBlur(this);
    }
    else this.current.fire('onBoxBlur');
    if(this.current.retrieveData('small') && ! input.get('value') && this.options.get('hideempty'))
      this.current.hide();
    this.current.removeClassName(this.options.get('className') + '-' + this.current.retrieveData('type') + '-focus');
    this.current = false;
    return this;
  },

  createBox: function(text, options) {
    var box = new Element('li', options).addClassName(this.options.get('className') + '-box').update(text.caption).cacheData('type', 'box');
    return box;
  },

  createInput: function(options) {
    var opts = Object.extend(options,{'type': 'text', 'autocomplete':'off'});
    var li = new Element('li', {className: this.options.get('className') + '-input'});
    var el = new Element('input', options);
    el.observe('click', function(e) { e.stop(); }).observe('focus', function(e) { if(! this.isSelfEvent('focus')) this.focus(li, true); }.bind(this)).observe('blur', function() { if(! this.isSelfEvent('blur')) this.blur(true); }.bind(this)).observe('keydown', function(e) { this.cacheData('lastvalue', this.value).cacheData('lastcaret', this.getCaretPosition()); });
    var tmp = li.cacheData('type', 'input').cacheData('input', el).insert(el);
    return tmp;
  },

  callEvent: function(el, type) {
    this.events.set(type, el);
    el[type]();
  },

  isSelfEvent: function(type) {
    return (this.events.get(type)) ? !! this.events.unset(type) : false;
  },

  makeResizable: function(li) {
    var el = li.retrieveData('input');
    el.cacheData('resizable', new ResizableTextbox(el, Object.extend(this.options.get('resizable'),{min: el.offsetWidth, max: (this.element.getWidth()?this.element.getWidth():50)})));
    return this;
  },

  checkInput: function() {
    var input = this.current.retrieveData('input');
    return (! input.retrieveData('lastvalue') || (input.getCaretPosition() === 0 && input.retrieveData('lastcaret') === 0));
  },

  move: function(direction) {
    var el = this.current[(direction == 'left' ? 'previous' : 'next')]();
    if(el && (! this.current.retrieveData('input') || ((this.checkInput() || direction == 'right')))) this.focus(el);
    return this;
  },

  moveDispose: function() {
    if(this.current.retrieveData('type') == 'box') return this.dispose(this.current);
    if(this.checkInput() && this.bits.keys().length && this.current.previous()) return this.focus(this.current.previous());
  }
});

//helper functions
Element.addMethods({
  getCaretPosition: function() {
    if (this.createTextRange) {
      var r = document.selection.createRange().duplicate();
      r.moveEnd('character', this.value.length);
      if (r.text === '') return this.value.length;
      return this.value.lastIndexOf(r.text);
    } else return this.selectionStart;
  },
  cacheData: function(element, key, value) {
    if (Object.isUndefined(this[$(element).identify()]) || !Object.isHash(this[$(element).identify()]))
      this[$(element).identify()] = $H();
    this[$(element).identify()].set(key,value);
    return element;
  },
  retrieveData: function(element,key) {
    return this[$(element).identify()].get(key);
  }
});

function $pick(){for(var B=0,A=arguments.length;B<A;B++){if(!Object.isUndefined(arguments[B])){return arguments[B];}}return null;}

var FacebookList = Class.create(TextboxList, {
  initialize: function($super,element, autoholder, options, func) {
    $super(element, options);
    this.loptions = $H({
      autocomplete: {
        'opacity': 1,
        'maxresults': 10,
        'minchars': 1
      }
    });

    this.id_base = $(element).identify() + "_" + this.options.get("className");

    this.data = [];
    this.data_searchable = [];
    this.autoholder = $(autoholder).setOpacity(this.loptions.get('autocomplete').opacity);
    this.autoholder.observe('mouseover',function() {this.curOn = true;}.bind(this)).observe('mouseout',function() {this.curOn = false;}.bind(this));
    this.autoresults = this.autoholder.select('ul').first();
	  var children = this.autoresults.select('li');
    children.each(function(el) { this.add({value:el.readAttribute('value'),caption:el.innerHTML}); }, this);

    // Loading the options list only once at initialize.
    // This would need to be further extended if the list was exceptionally long
    if (!Object.isUndefined(this.options.get('fetchFile'))) {
      new Ajax.Request(this.options.get('fetchFile'), {
        method: this.options.get('fetchMethod'),
        onSuccess: function(transport) {
          transport.responseText.evalJSON(true).each(function(t) {
            this.autoFeed(t) }.bind(this));
          }.bind(this)
        }
      );
    }
  },

  autoShow: function(search) {
    this.autoholder.setStyle({'display': 'block'});
    this.autoholder.descendants().each(function(e) { e.hide() });
    if(! search || ! search.strip() || (! search.length || search.length < this.loptions.get('autocomplete').minchars)) {
      this.autoholder.select('.default').first().setStyle({'display': 'block'});
      this.resultsshown = false;
    } else {
      this.resultsshown = true;
      this.autoresults.setStyle({'display': 'block'}).update('');
      if (!this.options.get('regexSearch')) {
        var matches = new Array();
        if (search) {
          if (!this.options.get('caseSensitive')) {
            search = search.toLowerCase();
          }
          var matches_found = 0;
          for (var i=0,len=this.data_searchable.length; i<len; i++) {
            if (this.data_searchable[i].indexOf(search) >= 0) {
              matches[matches_found++] = this.data[i];
            }
          }
        }
      } else {
        if (this.options.get('wordMatch')) {
          var regexp = new RegExp("(^|\\s)"+search,(!this.options.get('caseSensitive') ? 'i' : ''));
        } else {
          var regexp = new RegExp(search,(!this.options.get('caseSensitive') ? 'i' : ''));
          var matches = this.data.filter(
            function(str) {
            return str ? regexp.test(str.evalJSON(true).caption) : false;
          });
        }
      }

      var count = 0;
      matches = matches.compact();
      matches = matches.sortBy(function(m) {
        m = m.evalJSON(true);
        return m.value.startsWith(search);
      }).reverse();
      matches.each(
        function(result, ti) {
          count++;
          if(ti >= (this.options.get('maxResults') ? this.options.get('maxResults') : this.loptions.get('autocomplete').maxresults)) return;
          var that = this;
          var el = new Element('li');
          el.observe('click',function(e) {
              e.stop();
              that.current_input = "";
              that.autoAdd(this);
            }
          ).observe('mouseover', function() { that.autoFocus(this); } ).update(
            this.autoHighlight(result.evalJSON(true).caption, search)
          );
          this.autoresults.insert(el);
          el.cacheData('result', result.evalJSON(true));
          if(ti == 0) this.autoFocus(el);
        },
        this
      );
    }
    if (count == 0) {
      // if there are no results, hide everything so that KEY_ENTER has no effect
      this.autoHide();
    } else {
      if (count > this.options.get('results'))
        this.autoresults.setStyle({'height': (this.options.get('results')*24)+'px'});
      else
        this.autoresults.setStyle({'height': (count?(count*24):0)+'px'});
    }

    return this;
  },

  autoHighlight: function(html, highlight) {
    return html.gsub(new RegExp(highlight,'i'), function(match) {
      return '<em>' + match[0] + '</em>';
    });
  },

  autoHide: function() {
    this.resultsshown = false;
    this.autoholder.hide();
    return this;
  },

  autoFocus: function(el) {
    if(! el) return;
    if(this.autocurrent) this.autocurrent.removeClassName('auto-focus');
    this.autocurrent = el.addClassName('auto-focus');
    return this;
  },

  autoMove: function(direction) {
    if(!this.resultsshown) return;
    this.autoFocus(this.autocurrent[(direction == 'up' ? 'previous' : 'next')]());
    this.autoresults.scrollTop = this.autocurrent.positionedOffset()[1]-this.autocurrent.getHeight();
    return this;
  },

  autoFeed: function(text) {
    var with_case = this.options.get('caseSensitive');
    if (this.data.indexOf(Object.toJSON(text)) == -1) {
      this.data.push(Object.toJSON(text));
      this.data_searchable.push(with_case ? Object.toJSON(text).evalJSON(true).caption : Object.toJSON(text).evalJSON(true).caption.toLowerCase());
    }
    return this;
  },

  autoAdd: function(el) {
    if(this.newvalue && this.options.get("newValues")) {
      this.add({caption: el.value, value: el.value, newValue: true});
      var input = el;
    } else if(!el || ! el.retrieveData('result')) {
      return;
    } else {
      this.add(el.retrieveData('result'));
      delete this.data[this.data.indexOf(Object.toJSON(el.retrieveData('result')))];
      var input = this.lastinput || this.current.retrieveData('input');
    }
    this.autoHide();
    input.clear().focus();
    return this;
  },

  createInput: function($super,options) {
    var li = $super(options);
    var input = li.retrieveData('input');

    if(options['className'] == "maininput") {
      // Give the input a hook for our cucumber tests to use.
      input.setAttribute('name', 'fblist-maininput');
    };

    input.observe('keydown', function(e) {
      this.dosearch = false;
      this.newvalue = false;

      switch(e.keyCode) {
        case Event.KEY_UP: e.stop(); return this.autoMove('up');
        case Event.KEY_DOWN: e.stop(); return this.autoMove('down');

        case Event.KEY_RETURN:
          // If the text input is blank and the user hits Enter call the
          // onEmptyInput callback.
          if (String('').valueOf() == String(this.current.retrieveData('input').getValue()).valueOf()) {
            this.options.get("onEmptyInput")();
          }
          e.stop();
          if(!this.autocurrent || !this.resultsshown) break;
          this.current_input = "";
          this.autoAdd(this.autocurrent);
          this.autocurrent = false;
          this.autoenter = true;
          break;
        case Event.KEY_ESC:
          this.autoHide();
          if(this.current && this.current.retrieveData('input'))
            this.current.retrieveData('input').clear();
          break;
        default:
          this.dosearch = true;
      }
    }.bind(this));
    input.observe('keyup',function(e) {
      var code = this.options.get('separator').code;
      var splitOn = this.options.get('separator').value;
      switch(e.keyCode) {
        case code:
          if(this.options.get('newValues')) {
            new_value_el = this.current.retrieveData('input');
            if (!new_value_el.value.endsWith('<')) {
              keep_input = "";
              if (new_value_el.value.indexOf(splitOn) < (new_value_el.value.length - splitOn.length)){
                separator_pos = new_value_el.value.indexOf(splitOn);
                keep_input = new_value_el.value.substr(separator_pos + 1);
                new_value_el.value = new_value_el.value.substr(0,separator_pos).escapeHTML().strip();
              } else {
                new_value_el.value = new_value_el.value.gsub(splitOn,"").escapeHTML().strip();
              }
              if(!this.options.get("spaceReplace").blank()) new_value_el.value.gsub(" ", this.options.get("spaceReplace"));
              if(!new_value_el.value.blank()) {
                e.stop();
                this.newvalue = true;
                this.current_input = keep_input.escapeHTML().strip();
                this.autoAdd(new_value_el);
                input.value = keep_input;
                this.update();
              }
            }
          }
          break;
        case Event.KEY_UP:
        case Event.KEY_DOWN:
        case Event.KEY_RETURN:
        case Event.KEY_ESC:
          break;
        default:
          // If the user doesn't add comma after, the value is discarded upon submit
          this.current_input = input.value.strip().escapeHTML();
          this.update();

          // Removed Ajax.Request from here and moved to initialize,
          // now doesn't create server queries every search but only
          // refreshes the list on initialize (page load)
          if(this.searchTimeout) clearTimeout(this.searchTimeout);
            this.searchTimeout = setTimeout(function(){
              var sanitizer = new RegExp("[({[^$*+?\\\]})]","g");
              if(this.dosearch) this.autoShow(input.value.replace(sanitizer,"\\$1"));
          }.bind(this), 250);
      }
    }.bind(this));
    input.observe(Prototype.Browser.IE ? 'keydown' : 'keypress', function(e) {
      if ((e.keyCode == Event.KEY_RETURN) && this.autoenter) e.stop();
      this.autoenter = false;
    }.bind(this));
    return li;
  },

  createBox: function($super,text, options) {
    var li = $super(text, options);
    li.observe('mouseover',function() {
      this.addClassName('bit-hover');
    }).observe('mouseout',function() {
      this.removeClassName('bit-hover');
    });
    var a = new Element('a', {
      'href': '#',
      'class': 'closebutton'
    });
    a.observe('click',function(e) {
      e.stop();
      if(! this.current) this.focus(this.maininput);
      this.dispose(li);
    }.bind(this));
    li.insert(a).cacheData('text', Object.toJSON(text));
    return li;
  }
});

Element.addMethods({
  onBoxDispose: function(item,obj) {
  // Set to not to "add back" values in the drop-down upon delete if they were new values
	item = item.retrieveData('text').evalJSON(true);
	if(!item.newValue)
    	obj.autoFeed(item);
  },
  onInputFocus: function(el,obj) { obj.autoShow(); },
  onInputBlur: function(el,obj) {
    obj.lastinput = el;
    if(!obj.curOn) {
        obj.blurhide = obj.autoHide.bind(obj).delay(0.1);
    }
  },
  filter: function(D,E) { var C=[];for(var B=0,A=this.length;B<A;B++){if(D.call(E,this[B],B,this)){C.push(this[B]);}} return C; }
});

