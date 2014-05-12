Blacklight.onLoad(function() {
  $(".sorts-dash").click(function(){
    var itag =$(this).find('i');
    toggle_icon(itag);
    sort = itag.attr('class') == "caret" ? itag.attr('id')+' desc' :  itag.attr('id') +' asc';
    $('#sort').val(sort).selected = true;
    $("#dashboard_sort_submit").click();
  });

  $(".sorts").click(function(){
    var itag =$(this).find('i');
    toggle_icon(itag);
    sort = itag.attr('class') == "caret up" ? itag.attr('id')+' desc':  itag.attr('id');
    $('input[name="sort"]').attr('value', sort);
    $("#user_submit").click();
  });
});

function toggle_icon(itag){
       itag.toggleClass("caret");
       itag.toggleClass("caret up");
}
