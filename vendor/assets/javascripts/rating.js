// JavaScript Ratings, based on original Super Star Rating by Andrea Franz
// (see http://github.com/pilu/super-star-rating/tree/master).
//
//=============================================================================
var Star = Class.create({

  //---------------------------------------------------------------------------
  initialize: function(element, ratable) {
    this.element = element;
    this.ratable = ratable;
    this.selected = false;
    this.initial = this.element.className;
    this.element.observe("mouseover", this.on_mouseover.bind(this));    
  },  

  //---------------------------------------------------------------------------
  on_mouseover: function(event) {    
    this.ratable.select(this);
  },  

  //---------------------------------------------------------------------------
  set: function() {
    this.element.addClassName("on");
    this.selected = true;
  },  

  //---------------------------------------------------------------------------
  clear: function() {  
    this.element.removeClassName("on");
    this.selected = false;
  },

  //---------------------------------------------------------------------------
  reset: function() {  
    this.element.className = this.initial;
  }
});

//=============================================================================
var Ratable = Class.create({

  //---------------------------------------------------------------------------
  initialize: function(element) {
    this.element = element;
    this.dirty = false;
    this.clicked = false;
    this.options = Object.extend({
      callback: Prototype.emptyFunction,
      remote_url: null,
      remote_method: "POST",
      remote_parameters: ""
    }, arguments[1] || {}); 
    
    this.stars = new Array();
    this.element.select(".star").each(function(element) {
      this.stars.push(new Star(element, this));      
    }.bind(this));
    this.rating = this.score();
    
    this.container = this.element.down(".stars");    
    this.container.observe("mouseover", this.on_mouseover.bind(this));
    this.container.observe("mouseout", this.on_mouseout.bind(this));
    this.container.observe("click", this.on_click.bind(this));
  },  

  //---------------------------------------------------------------------------
  on_mouseover: function(event) {
    this.element.addClassName("selected");
  },  

  //---------------------------------------------------------------------------
  on_mouseout: function(event) {
    if (!this.clicked) {
      this.element.removeClassName("selected");
      if (this.dirty) {
        this.clear();
        if (this.rating != 0) {
          this.notify();
        }
      } else {
        this.reset();
      }
    }
    this.clicked = false;
  },  

  //---------------------------------------------------------------------------
  on_click: function(event) {
    this.dirty = this.clicked = true;
    this.notify();
  },  

  //---------------------------------------------------------------------------
  notify: function() {
    this.rating = this.score();
    this.options.callback(this.element, this.rating);
    if (this.options.remote_url) {
      var parameters = new Template(this.options.remote_parameters).evaluate({id: this.element.id, rating: this.rating});
      new Ajax.Request(this.options.remote_url, { method: this.options.remote_method, parameters: parameters });
    }
  },  

  //---------------------------------------------------------------------------
  reset: function() {  
    this.stars.each(function(star) {
      star.reset();
    });    
  },      

  //---------------------------------------------------------------------------
  clear: function() {  
    this.stars.each(function(star) {
      star.clear();
    });    
  },      

  //---------------------------------------------------------------------------
  score: function() {
    var score;
    for (score = 0;  score < this.stars.length;  score++) {
      if (!this.stars[score].selected) {
        break;
      }
    }
    return score;
  },  

  //---------------------------------------------------------------------------
  select: function(selected) {
    var clear = false;
    this.stars.each(function(star) {
      clear ? star.clear() : star.set();
      if (star == selected) {
        clear = true;
      }
    });
  }  
});

//=============================================================================
var Rating = Class.create({
  initialize: function() {
    this.class_name = arguments[0] || ".rating";
    this.options = arguments[1] || {};
    this.elements = new Array();

    Ajax.Responders.register({
      onComplete: this.parse.bind(this)
    });
    this.parse();
  },  

  //---------------------------------------------------------------------------
  parse: function() {
    $$(this.class_name).each(function(element) {
      if (!this.elements.include(element)) {
        this.elements.push(element);
        new Ratable(element, this.options);
      }      
    }.bind(this));
  }
});
