function display_message(message, alert){
  $("#game").before("<div class=\"alert alert-" + alert + " fade show\" role=\"alert\">" + message + "</div>");
  setTimeout(function(){
    $(".alert").alert('close');
  }, 3000);
}