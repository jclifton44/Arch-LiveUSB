// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
var pageVisitUrl='https://jeremy-clifton.com/history/pageVisit/'
var commitUrl='https://jeremy-clifton.com/history/writeCommit/'
var historyPaginationKey="error"
var data
var fail = function(res){
  //alert('pageVisit not accepted')
  alert(res)
} 
var success = function(res){
  //alert('res')
}

$(document).ready(function() {
  //alert(window.location)

  var data={
    site: window.location.toString()
  }

  $.ajax({
    type:"POST",
    url:commitUrl,
    fail:function(res){
      alert(res)
      alert("A Request Logger error occured")
    },
    success: function(res){
      historyPaginationKey=JSON.parse(res)['name']
      //alert(pageVisitUrl+historyPaginationKey+'/')
      $.ajax({
        type: "POST",
        url: pageVisitUrl+historyPaginationKey+'/',
        //contentType: false,
        data: data,
        fail: fail,
        success: success,
      })
    }
  })
  
  //if(window.jQuery) {
  //  //alert("jquery working again")
  //} else {
  //  alert("jquery NOT working")
  //}
});