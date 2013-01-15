function getTimeLimitData(){
  return JSON.parse($('#protected_statuses')[0].getAttribute('data'));
}

function showHideLogTimeFieldset() {
  var data = getTimeLimitData();
  var new_status_id = $('#issue_status_id')[0].value;
  var log_time_fieldset = $('#time_entry_hours').parents('fieldset.tabular:first')[0];
  var hide = (($.inArray(new_status_id, data.protected_status_ids) > 0) && ($.inArray(data.initial_status_id, data.protected_status_ids) > 0))
  timeLimitShowHideElement(log_time_fieldset, hide)
}

function hideShowLogTimeIconIfProtected() {
  var data = getTimeLimitData();
  var log_time_icon = $('a.icon-time-add');
  var hide = ($.inArray(data.initial_status_id, data.protected_status_ids) > 0)

  for (var i = 0; i < log_time_icon.length; i++) {
    timeLimitShowHideElement(log_time_icon[i], hide);
  }
}

function timeLimitShowHideElement(element, hide) {
  if (hide) {
    element.style.display = 'none';
  } else {
    element.style.display = '';
  }
}

hideShowLogTimeIconIfProtected();

$(document.body).ready(function() {
  // call this function twice: in loading process and after document ready
  // first calling to avoid displaying/blinking "Log time" at top
  // seconnd one to hide "Log time" at bottom
  hideShowLogTimeIconIfProtected();
  if ($('#issue_status_id')[0]) {
    showHideLogTimeFieldset();
    $('#issue_status_id')[0].onchange = showHideLogTimeFieldset;
  }
})
