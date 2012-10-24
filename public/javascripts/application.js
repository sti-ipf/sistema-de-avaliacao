// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function calculate_number_of_people(id){
  var one = convert_to_int($("#one_" + id).val());
  var two = convert_to_int($("#two_" + id).val());
  var three = convert_to_int($("#three_" + id).val());
  var four = convert_to_int($("#four_" + id).val());
  var five = convert_to_int($("#five_" + id).val());
  var do_not_know = convert_to_int($("#do_not_know_" + id).val());
  var do_not_answer = convert_to_int($("#do_not_answer_" + id).val());
  $("#quantity_of_people_" + id).val(one + two + three + four + five + do_not_know + do_not_answer);
  $("#quantity_of_people_" + id).trigger("blur");
}

function convert_to_int(value){
	if(value == '')
		return 0;
	else
		return parseInt(value);
}



String.prototype.unescapeHtml = function () {
    var temp = document.createElement("div");
    temp.innerHTML = this;
    var result = temp.childNodes[0].nodeValue;
    temp.removeChild(temp.firstChild);
    return result;
}

function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").slideToggle("show");
}

function add_fields(link, association, content) {
  var numItems = $('.fields').length
  var new_id = numItems
  var regexp = new RegExp("new_" + association, "g")
  $(link).before(content.unescapeHtml().replace(regexp, new_id));  
  return false;
}
