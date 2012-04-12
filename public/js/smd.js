
jQuery(document).ready(function(){

//  $('#date').datepicker();
  
  // call accordion 
  $( "#accordion" ).accordion({ active: -1, collapsible: true });

  // get server responce async
  // $( "#resbody" ).load('sres');

  setInterval(function() {
      $( "#resbody" ).load('sres');
  }, 2000);
});