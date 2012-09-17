(function($){

  $.fn.disable = function(){
    return this.each(function(){
      var $this = $(this);
      $this.prepend('<div class="disabled_shield"></div>');
      var shield = $this.find('.disabled_shield');
      shield.css({'position' : 'absolute', 'z-index' : '200'});
      shield.width($this.width());
      shield.height($this.height());
      $this.data("disabledShield", shield);
      $this.animate({opacity : 0.5}, 200);
      $this.find('input:focus').blur();
    });
  };
  
  $.fn.enable = function(){
    var $this = $(this);
    $this.find('.disabled_shield').remove();
    $this.animate({opacity: 100}, 200);
  };
  
})(jQuery);
