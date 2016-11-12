window.onload = function(){
  var crystal = CodeMirror.fromTextArea(document.querySelector("#crystal-code-wrapper>textarea"),{mode:"crystal"});
  var cpp = CodeMirror(document.querySelector("#cpp-code-wrapper"),{value:"/* C++ code would appear here */",mode:"clike"});



  Jackbox.init();
  $("#tbtn-wrapper>button").click(function(){
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
          data.warnings.forEach(function(e){
            console.warning(e);
            Jackbox.warning(e.message + " ! See console for more info");
          });
          data.errors.forEach(function(e){
            console.error(e);
            Jackbox.error(e.message + " ! See console for more info");
          });
          cpp.setValue(data.code);
        }
      },
      crossDomain : true,
      error : function(e,ee,eee){
        console.log(e);
        console.log(ee);
        console.log(eee);
        Jackbox.error("RequestError! See console for more info");
      },
      url: "https://cppize-aas.herokuapp.com"
    });
  });
};
