//over ride the blacklight default to submit
//form when sort by or show per page change
Blacklight.do_select_submit = function() {
  $(Blacklight.do_select_submit.selector).each(function() {
        var select = $(this);
        select.closest("form").find("input[type=submit]").show();
        select.bind("change", function() {
          return false;
        });
    });
};
Blacklight.do_select_submit.selector = "form.sort select, form.per_page select";

function notify_update_link() {
   $('#notify_update_link').click();
}

Blacklight.onLoad(function() {

  // set up global batch edit options to override the ones in the gem
  window.batch_edits_options = { checked_label: "",unchecked_label: "",progress_label: "",status_label: "",css_class: "batch_toggle"};

  setInterval(notify_update_link, 30*1000);

  // bootstrap alerts are closed this function
  $(document).on('click', '.alert .close' , function(){
    $(this).parent().hide();
  });

  $.fn.selectRange = function(start, end) {
    return this.each(function() {
        if (this.setSelectionRange) {
            this.focus();
            this.setSelectionRange(start, end);
        } else if (this.createTextRange) {
            var range = this.createTextRange();
            range.collapse(true);
            range.moveEnd('character', end);
            range.moveStart('character', start);
            range.select();
        }
    });
  };

  // show/hide more information on the dashboard when clicking
  // plus/minus
  $('.glyphicon-plus').on('click', function() {
    var button = $(this);
    //this.id format: "expand_NNNNNNNNNN"
    var array = this.id.split("expand_");
    if (array.length > 1) {
      var docId = array[1];
      $("#detail_" + docId + " .expanded-details").slideToggle();
      button.toggleClass('glyphicon-plus glyphicon-minus');
    }
    return false;
  });

  $('#add_descriptions').click(function() {
      $('#more_descriptions').show();
      $('#add_descriptions').hide();
      return false;
  });

  $("a[rel=popover]").click(function() { return false;});

  /*
   *  Tag cloud(s)
   */
  $(".tagcloud").blacklightTagCloud({
    size: {start: 0.9, end: 2.5, unit: 'em'},
    cssHooks: {granularity: 15},
    // color: {start: '#cde', end: '#f52'}
  });


  /*
   * facets lists
   */
  $("li.expandable").click(function(){
    $(this).next("ul").slideToggle();
    $(this).find('i').toggleClass("icon-chevron-down");
  });

  $("li.expandable_new").click(function(){
    $(this).find('i').toggleClass("icon-chevron-down");
  });

}); //closing function at the top of the page


