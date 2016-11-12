window.onload = function(){
  var crystal = CodeMirror.fromTextArea($("#crystal-code-wrapper>textarea").context,{language:"crystal"});
  var cpp = CodeMirror($("#cpp-code-wrapper").context,{value:"/* C++ code would appear here */",language:"clike"});



  //Jackbox.init();
  $("#transpile-button>button").click(function(){
    $.ajax({
      method: "POST",
      data: crystal.getValue(),
      dataType : "json",
      success : function(data){
        console.log(data);
        if(data.error)
        {
          cpp.setValue("/*Error ! See console for more info*/");
        }
        else
        {
          cpp.setValue(data.code);
        }
      },
      crossDomain : true,
      error : function(e,ee,eee){
        console.log(e);
        console.log(ee);
        console.log(eee);
        cpp.setValue("/*Request Error ! See console for more info*/");
      },
      url: "https://cppize-aas.herokuapp.com"
    });
  });
};
