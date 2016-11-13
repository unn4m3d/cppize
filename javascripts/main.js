var modal_data = [];


function showModal(id)
{
  console.log(id);
  $("#msg-modal").modal().open(
    {
      onOpen : function(el,opts){
        let div = el.find("div#modal-content");
        div.html("");
        el.find("#modal-header").html("<span class='"+modal_data[id].m_type+"'>"+modal_data[id].m_type + "</span>");
        div.append("<h2>Info</h2>");
        div.append("<pre><code>"+JSON.stringify(modal_data[id],null,"\t")+"</pre></code>");
      }
    }
  );
}

function pushModal(data)
{
  var i = modal_data.length;
  modal_data[i] = data;
  return i;
}

window.onload = function()
{
  var crystal = CodeMirror.fromTextArea(document.querySelector("#crystal-code-wrapper>textarea"),{mode:"crystal"});
  var cpp = CodeMirror(document.querySelector("#cpp-code-wrapper"),{value:"/* C++ code would appear here */",mode:"clike"});

  Jackbox.init();
  $(".modal .close").click(function(e){
    e.preventDefault();
    $.modal().close();
  });

  $("div#jackbox").click(function(e){
    console.log(e);
    var class_s = $(e.target).parent("div.notification").attr("class");
    if(typeof class_s !== "undefined")
    {
      var classes = class_s.split(/\s+/);
      for(let c of classes)
      {
        let arr = c.match(/message-id-(\d+)/);
        if(arr)
        {
          showModal(arr[0].match(/(\d+)/)[0]);
        }
      }
    }
  });
  $("#tbtn-wrapper>button").click(function(){
    Jackbox.information("Transpiling...");
    var code = crystal.getValue();
    $("#tbtn-wrapper input[type=checkbox]").each(function(){
      code += "\n#=:cppize-feature:= " + $(this).data("option") + "\n\n";
    });
    $.ajax({
      method: "POST",
      data: code,
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
            console.warn(e);
            e.m_type = "warning";
            let i = pushModal(e);
            Jackbox.warning(
              e.message + " ! See console for more info",
              {classNames: ["message-id-"+i]}
            );
          });
          data.errors.forEach(function(e){
            console.error(e);
            e.m_type = "error";
            let i = pushModal(e);
            Jackbox.error(
              e.message + " ! See console for more info",
              {classNames: ["message-id-"+i]}
            );
          });
          if(data.errors.length < 1)
          {
            Jackbox.success("Transpiled successfully");
          }
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
  Jackbox.information("Cppize transpiler is ready!");
};
