window.onload = function(){
  var flask = new CodeFlask;
  var code = "";
  flask.run("#crystal-code-wrapper",{language: "crystal"});
  flask.onUpdate(function(c){code = c});
  //Jackbox.init();
  $("#transpile-button>button").click(function(){
    $.ajax({
      method: "POST",
      data: code,
      dataType : "json",
      success : function(data){
        console.log(data);
        if(data.error)
        {
          $("#output code").text("/*Error ! See console for more info*/");
        }
        else
        {
          $("#output code").text(data.code);
        }
      },
      error : function(e,ee,eee){
        console.log(e);
        console.log(ee);
        console.log(eee);
        $("#output code").text("/*Request Error ! See console for more info*/");
      },
      url: "https://cppize-aas.herokuapp.com"
    });
  });
};
