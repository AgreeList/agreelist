// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require bootstrap
//= require react
//= require react_ujs
//= require components
//= require_tree .

$(document).ready(function() {
  statements_observers();
  sessions_observers();

  $(".vote").click(function(event) {
    var vote = $(this).attr("vote");
    var statement_id = $(this).attr("statement_id");
    $("#vote-twitter-login").attr("href", "/auth/twitter?task=voting&vote=" + vote + "&statement_id=" + statement_id);
  });

  $(".upvote").click(function(event) {
    var agreement_id = $(this).attr("agreement_id");
    $("#upvote-twitter-login").attr("href", "/auth/twitter?task=upvote&agreement_id=" + agreement_id);
    $("#upvote-email-login").attr("href", "/login?task=upvote&agreement_id=" + agreement_id);
  });

  $("#create-question").click(function(event) {
    var question = $("#content").val();
    $("#create-twitter-login").attr("href", "/auth/twitter?task=post&content=" + question);
  });

  $(".see_more_reason").click(function() {
    var agreement_id = $(this).attr("agreement_id");
    var reason = $("#reason_" + agreement_id)
    var full_reason = reason.attr("full_reason");
    reason.text(full_reason);
    $(this).hide();
  });
});
