function showHideLogTime() {
  var protected_statuses = $('#protected_statuses')[0].getAttribute('data');
  var new_status_id = $('#issue_status_id')[0].value
  var log_time = $('#time_entry_hours').parents('fieldset.tabular:first')[0]
  if ($.inArray(new_status_id, protected_statuses) > 0 && $.inArray(initial_status_id, protected_statuses) > 0) {
    log_time.style.display = 'none';
  } else {
    log_time.style.display = '';
  }
}

$(document).ready(function() {
  if ($('#issue_status_id')[0]) {
    initial_status_id = $('#issue_status_id')[0].value;
    showHideLogTime();
    $('#issue_status_id')[0].onchange = showHideLogTime;
  }
})
