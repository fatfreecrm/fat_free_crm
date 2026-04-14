/**
 * Plugin Name: areacomplete
 * Author: Amir Harel, Sean Templeton, Nathan Broadbent
 * Copyright: amir harel (harel.amir1@gmail.com)
 * Twitter: @amir_harel
 * Version 1.4.1
 * Published at : http://www.amirharel.com/2011/03/07/implementing-autocomplete-jquery-plugin-for-textarea/
 */

(function($){
  /**
   * @param obj
   *  @attr wordCount {Number} the number of words the user want to for matching it with the dictionary
   *  @attr mode {String} set "outter" for using an autocomplete that is being displayed in the outter layout of the textarea, as opposed to inner display
   *  @attr on {Object} containing the followings:
   *    @attr query {Function} will be called to query if there is any match for the user input
   */
  $.fn.areacomplete = function(obj){
    if( typeof $.browser.msie != 'undefined' ) obj.mode = 'outter';
    this.each(function(index,element){
      if( element.nodeName == 'TEXTAREA' ){
        makeAutoComplete(element,obj);
      }
    });
  }

  var browser =  {isChrome: $.browser.webkit };

  function getTextAreaSelectionEnd(ta) {
     var textArea = ta;//document.getElementById('textarea1');
     if (document.selection) { //IE
      var bm = document.selection.createRange().getBookmark();
      var sel = textArea.createTextRange();
      sel.moveToBookmark(bm);
      var sleft = textArea.createTextRange();
      sleft.collapse(true);
      sleft.setEndPoint("EndToStart", sel);
      return sleft.text.length + sel.text.length;
    }
    return textArea.selectionEnd; //ff & chrome
  }

  function getDefaultCharArray(){
    return  {
    '`':0,
    '~':0,
    '1':0,
    '!':0,
    '2':0,
    '@':0,
    '3':0,
    '#':0,
    '4':0,
    '$':0,
    '5':0,
    '%':0,
    '6':0,
    '^':0,
    '7':0,
    '&':0,
    '8':0,
    '*':0,
    '9':0,
    '(':0,
    '0':0,
    ')':0,
    '-':0,
    '_':0,
    '=':0,
    '+':0,
    'q':0,
    'Q':0,
    'w':0,
    'W':0,
    'e':0,
    'E':0,
    'r':0,
    'R':0,
    't':0,
    'T':0,
    'y':0,
    'Y':0,
    'u':0,
    'U':0,
    'i':0,
    'I':0,
    'o':0,
    'O':0,
    'p':0,
    'P':0,
    '[':0,
    '{':0,
    ']':0,
    '}':0,
    'a':0,
    'A':0,
    's':0,
    'S':0,
    'd':0,
    'D':0,
    'f':0,
    'F':0,
    'g':0,
    'G':0,
    'h':0,
    'H':0,
    'j':0,
    'J':0,
    'k':0,
    'K':0,
    'l':0,
    'L':0,
    ';':0,
    ':':0,
    '\'':0,
    '"':0,
    '\\':0,
    '|':0,
    'z':0,
    'Z':0,
    'x':0,
    'X':0,
    'c':0,
    'C':0,
    'v':0,
    'V':0,
    'b':0,
    'B':0,
    'n':0,
    'N':0,
    'm':0,
    'M':0,
    ',':0,
    '<':0,
    '.':0,
    '>':0,
    '/':0,
    '?':0,
    ' ':0
    };
  }


  function setCharSize(data){
    for( var ch in data.chars ){
      if( ch == ' ' ) $(data.clone).html("<span id='test-width_"+data.id+"' style='line-block'>&nbsp;</span>");
      else $(data.clone).html("<span id='test-width_"+data.id+"' style='line-block'>"+ch+"</span>");
      var testWidth = $("#test-width_"+data.id).width();
      data.chars[ch] = testWidth;
    }
  }

  var _data = {};
  var _count = 0;
  function makeAutoComplete(ta,obj){
    _count++;
    _data[_count] = {
      id:"auto_"+_count,
      ta:ta,
      wordCount:obj.wordCount,
      on:obj.on,
      clone:null,
      lineHeight:0,
      list:null,
      charInLines:{},
      mode:obj.mode,
      chars:getDefaultCharArray()};

    var clone = createClone(_count);
    _data[_count].clone = clone;
    setCharSize(_data[_count]);
    //_data[_count].lineHeight = $(ta).css("font-size");

    var ta_id = $(ta).attr('id')
    $(ta).after("<div class='areacomplete-dropdown' id='areacomplete_"+ta_id+"'><ul class='auto-list'></ul></div>");
    _data[_count].list = $('.auto-list').first()

    registerEvents(_data[_count]);
  }


  function createClone(id){
    var data = _data[id];
    var div = document.createElement("div");
    var offset = $(data.ta).offset();
    offset.top = offset.top - parseInt($(data.ta).css("margin-top"));
    offset.left = offset.left - parseInt($(data.ta).css("margin-left"));
    //console.log("createClone: offset.top=",offset.top," offset.left=",offset.left);
    $(div).css({
      position:"absolute",
      top: offset.top,
      left: offset.left,
      "border-collapse" : $(data.ta).css("border-collapse"),
      "border-bottom-style" : $(data.ta).css("border-bottom-style"),
      "border-bottom-width" : $(data.ta).css("border-bottom-width"),
      "border-left-style" : $(data.ta).css("border-left-style"),
      "border-left-width" : $(data.ta).css("border-left-width"),
      "border-right-style" : $(data.ta).css("border-right-style"),
      "border-right-width" : $(data.ta).css("border-right-width"),
      "border-spacing" : $(data.ta).css("border-spacing"),
      "border-top-style" : $(data.ta).css("border-top-style"),
      "border-top-width" : $(data.ta).css("border-top-width"),
      "direction" : $(data.ta).css("direction"),
      "font-size-adjust" : $(data.ta).css("font-size-adjust"),
      "font-size" : $(data.ta).css("font-size"),
      "font-stretch" : $(data.ta).css("font-stretch"),
      "font-style" : $(data.ta).css("font-style"),
      "font-family" : $(data.ta).css("font-family"),
      "font-variant" : $(data.ta).css("font-variant"),
      "font-weight" : $(data.ta).css("font-weight"),
      "width" : $(data.ta).css("width"),
      "height" : $(data.ta).css("height"),
      "letter-spacing" : $(data.ta).css("letter-spacing"),
      "margin-bottom" : $(data.ta).css("margin-bottom"),
      "margin-top" : $(data.ta).css("margin-top"),
      "margin-right" : $(data.ta).css("margin-right"),
      "margin-left" : $(data.ta).css("margin-left"),
      "padding-bottom" : $(data.ta).css("padding-bottom"),
      "padding-top" : $(data.ta).css("padding-top"),
      "padding-right" : $(data.ta).css("padding-right"),
      "padding-left" : $(data.ta).css("padding-left"),
      "overflow-x" : "hidden",
      "line-height" :  $(data.ta).css("line-height"),
      "overflow-y" : "hidden",
      "z-index" : -10
    });

    //console.log("createClone: ta width=",$(data.ta).css("width")," ta clientWidth=",data.ta.clientWidth, "scrollWidth=",data.ta.scrollWidth," offsetWidth=",data.ta.offsetWidth," jquery.width=",$(data.ta).width());
    //i don't know why by chrome adds some pixels to the clientWidth...
    data.chromeWidthFix = (data.ta.clientWidth - $(data.ta).width());
    data.lineHeight = $(data.ta).css("line-height");
    if( isNaN(parseInt(data.lineHeight)) ) data.lineHeight = parseInt($(data.ta).css("font-size"))+2;
    document.body.appendChild(div);
    return div;
  }


  function getWords(data){
    var selectionEnd = getTextAreaSelectionEnd(data.ta);//.selectionEnd;
    var text = data.ta.value;
    text = text.substr(0,selectionEnd);
    if( text.charAt(text.length-1) == ' ' || text.charAt(text.length-1) == '\n' ) return "";
    var ret = [];
    var wordsFound = 0;
    var pos = text.length-1;
    while( wordsFound < data.wordCount && pos >= 0 && text.charAt(pos) != '\n'){
      ret.unshift(text.charAt(pos));
      pos--;
      if( text.charAt(pos) == ' ' || pos < 0 ){
        wordsFound++;
      }
    }
    return ret.join("");
  }


  function showList(data, text, list){
    if( !data.listVisible ){
      data.listVisible = true;
      var pos = getCursorPosition(data);
      $(data.list).css({
        left: pos.left+"px",
        top: pos.top+"px",
        display: "block"
      });
    }

    var attrs, value, d;
    var regEx = new RegExp("("+text+")", "i");
    var taWidth = $(data.ta).width()-5;
    var width = data.mode == "outter" ? taWidth - 3 : "";
    $(data.list).empty();
    for( var i=0; i< list.length; i++ )
    {
      d = {};
      if(typeof list[i] == "string")
        value = list[i];
      else
      {
        value = list[i].value;
        d = list[i].data;
      }
      $(data.list).append($('<li>').css('width', width + 'px').attr({'data-value': value}).html(value.replace(regEx,"<em>$1</em>")).data(d));
    }
  }

  function breakLines(text,data){
    var lines = [];

    var width = $(data.clone).width();

    var line1 = "";
    var line1Width = 0;
    var line2Width = 0;
    var line2 = "";
    var chSize = data.chars;


    var len = text.length;
    for( var i=0; i<len; i++){
      var ch = text.charAt(i);
      line2 += ch.replace(" ","&nbsp;");
      var size = (typeof chSize[ch] == 'undefined' ) ? 0 : chSize[ch];
      line2Width += size;
      if( ch == ' '|| ch == '-' ){
        if( line1Width + line2Width < width-1 ){
          line1 = line1 + line2;
          line1Width = line1Width + line2Width;
          line2 = "";
          line2Width = 0;
        }
        else{
          lines.push(line1);
          line1= line2;
          line1Width = line2Width;
          line2= "";
          line2Width = 0;
        }
      }
      if( ch == '\n'){
        if( line1Width + line2Width < width-1 ){
          lines.push(line1 + line2);
        }
        else{
          lines.push(line1);
          lines.push(line2);
        }
        line1 = "";
        line2 = "";
        line1Width = 0;
        line2Width = 0;
      }
      //else{
        //line2 += ch;
      //}
    }
    if( line1Width + line2Width < width-1 ){
      lines.push(line1 + line2);
    }
    else{
      lines.push(line1);
      lines.push(line2);
    }
    return lines;
  }




  function getCursorPosition(data){
    if( data.mode == "outter" ){
      return getOuterPosition(data);
    }
    //console.log("getCursorPosition: ta width=",$(data.ta).css("width")," ta clientWidth=",data.ta.clientWidth, "scrollWidth=",data.ta.scrollWidth," offsetWidth=",data.ta.offsetWidth," jquery.width=",$(data.ta).width());
    if( browser.isChrome ){
      $(data.clone).width(data.ta.clientWidth-data.chromeWidthFix);
    }
    else{
      $(data.clone).width(data.ta.clientWidth);
    }


    var ta = data.ta;
    var selectionEnd = getTextAreaSelectionEnd(data.ta);
    var text = ta.value;//.replace(/ /g,"&nbsp;");

    var subText = text.substr(0,selectionEnd);
    var restText = text.substr(selectionEnd,text.length);

    var lines = breakLines(subText,data);//subText.split("\n");
    var miror = $(data.clone);

    miror.html("");
    for( var i=0; i< lines.length-1; i++){
      miror.append("<div style='height:"+(parseInt(data.lineHeight))+"px"+";'>"+lines[i]+"</div>");
    }
    miror.append("<span id='"+data.id+"' style='display:inline-block;'>"+lines[lines.length-1]+"</span>");

    miror.append("<span id='rest' style='max-width:'"+data.ta.clientWidth+"px'>"+restText.replace(/\n/g,"<br/>")+"&nbsp;</span>");

    miror.get(0).scrollTop = ta.scrollTop;

    var span = miror.children("#"+data.id);
    var offset = span.offset();

    return {top:offset.top+span.height(),left:offset.left+span.width()};

  }

  function getOuterPosition(data){
    var offset = $(data.ta).offset();
    return {top:offset.top+$(data.ta).height()+8,left:offset.left};
  }

  function hideList(data){
    if( data.listVisible ){
      $(data.list).css("display","none");
      data.listVisible = false;
    }
  }

  // Selects the first element if none are selected
  function ensureSelected(data) {
    var selected = $(data.list).find("[data-selected=true]");
    if( selected.length != 1 ){
      var new_selected = $(data.list).find("li:first-child")
      new_selected.attr("data-selected","true");
    }
    if (new_selected[0]) { scrollIntoView(new_selected[0]); }
  }

  function setSelected(dir, data){
    var selected = $(data.list).find("[data-selected=true]");
    // Don't allow selection to wrap from bottom
    if( selected.length != 1 && dir > 0 ){
      var new_selected = $(data.list).find("li:first-child")
      new_selected.attr("data-selected","true");
    } else {
      var new_selected = dir > 0 ? selected.next() : selected.prev();
      // Don't unselect the last element when pressing down arrow,
      // but DO unselect it if pressing UP from the first element
      if (new_selected[0] || dir < 0) {
        selected.attr("data-selected","false");
        new_selected.attr("data-selected","true");
      }
    }
    // Set scroll position on ul
    if (new_selected[0]) { scrollIntoView(new_selected[0]); }
  }

  function scrollIntoView(element) {
    var container = element.offsetParent;
    var containerTop = $(container).scrollTop();

    var containerBottom = containerTop + $(container).height();
    var elemTop = element.offsetTop;
    var elemBottom = elemTop + $(element).height() + 4;

    if (elemTop < containerTop) {
      $(container).scrollTop(elemTop);
    } else if (elemBottom > containerBottom) {
      $(container).scrollTop(elemBottom + 4 - $(container).height());
    }
  }


  function getCurrentSelected(data){
    var selected = $(data.list).find("[data-selected=true]");
    if( selected.length == 1) return selected.get(0);
    return null;
  }

  function onUserSelected(li,data){
    var selectedText = $(li).attr("data-value");

    var selectionEnd = getTextAreaSelectionEnd(data.ta);//.selectionEnd;
    var text = data.ta.value;
    text = text.substr(0,selectionEnd);
    //if( text.charAt(text.length-1) == ' ' || text.charAt(text.length-1) == '\n' ) return "";
    //var ret = [];
    var wordsFound = 0;
    var pos = text.length-1;

    while( wordsFound < data.wordCount && pos >= 0 && text.charAt(pos) != '\n'){
      pos--;
      if( text.charAt(pos) == ' ' || pos < 0 ){
        wordsFound++;
      }
    }
    var a = data.ta.value.substr(0, pos + 1);
    var c = data.ta.value.substr(selectionEnd, data.ta.value.length);
    var scrollTop = data.ta.scrollTop;
    if(data.on && data.on.selected)
      var retText = data.on.selected(selectedText, $(li).data());
    if(retText) selectedText = retText;
    data.ta.value = a + selectedText + ' ' + c;
    data.ta.scrollTop = scrollTop;
    data.ta.selectionEnd = pos + 2 + selectedText.length;
    hideList(data);
    $(data.ta).focus();
  }

  function registerEvents(data){
    $(data.list).delegate("li","click",function(e){
      var li = this;
      onUserSelected(li,data);
      e.stopPropagation();
      e.preventDefault();
      return false;
    });



    $(data.ta).blur(function(e){
      setTimeout(function(){
        hideList(data);
      }, 400);

    });

    $(data.ta).click(function(e){
      hideList(data);
    });

    $(data.ta).keydown(function(e){
      //console.log("keydown keycode="+e.keyCode);
      if( data.listVisible ){
        switch(e.keyCode){
          case 27: //esc
            hideList(data);
            return false;
          case 40: // up
            setSelected(+1,data);
            e.stopImmediatePropagation();
            e.preventDefault();
            return false;
          case 38: // down
            setSelected(-1,data);
            e.stopImmediatePropagation();
            e.preventDefault();
            return false;
        }

        if( e.keyCode == 13 ){//enter key
          var li = getCurrentSelected(data);
          if( li ){
            e.stopImmediatePropagation();
            e.preventDefault();
            hideList(data);
            onUserSelected(li,data);
            return false;
          }
          hideList(data);
        }
      }
    });

    $(data.ta).keyup(function(e){
      if( data.listVisible ){
        switch(e.keyCode){
          // Ignore arrow key / delete / end / home events
          case 37:
          case 38:
          case 39:
          case 40:
            e.stopImmediatePropagation();
            e.preventDefault();
            return false;
        }
      } else {
        switch(e.keyCode){
          // Ignore arrow key / delete / end / home events
          case 13:
          case 35:
          case 36:
          case 37:
          case 38:
          case 39:
          case 40:
          case 46:
            e.stopImmediatePropagation();
            e.preventDefault();
            return true;
        }
      }

      if (e.keyCode == 27) { return true }; // escape

      var text = getWords(data);
      //console.log("getWords return ",text);
      if( text != "" ){
        data.on.query(text,function(list, matching_text){
          //console.log("got list = ",list);
          if (typeof matching_text === "undefined") var matching_text = text;

          if( list.length ){
            showList(data, matching_text, list);
            ensureSelected(data);
          }
          else{
            hideList(data);
          }
        });
      }
      else{
        hideList(data);
      }
    });


    // Don't lose focus when scrolling the c with the mouse
    $(data.list).mousedown(function(e){
      e.stopImmediatePropagation();
      e.preventDefault();
      return false;
    });


    $(data.ta).scroll(function(e){
        var ta = e.target;
        var miror = $(data.clone);
        miror.get(0).scrollTop = ta.scrollTop;
      });
  }
})(jQuery);
