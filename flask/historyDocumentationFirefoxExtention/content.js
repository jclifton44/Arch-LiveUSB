var pageVisitUrl='https://jeremy-clifton.com/history/pageVisit/'
var commitUrl='https://jeremy-clifton.com/history/writeCommit/'
var historyPaginationKey="error"

var latestCommit = new XMLHttpRequest();
latestCommit.open("post",commitUrl, true)
//type, url, async
latestCommit.setRequestHeader("Content-Type", "application/x-www-urlencoded")
latestCommit.onreadystatechange = function() {
  if(this.readyState === XMLHttpRequest.DONE && this.status === 200){
    var sendSite = new XMLHttpRequest();
    console.log(latestCommit.response)
    historyPaginationKey=JSON.parse(latestCommit.response)['name']
    sendSite.open("post", pageVisitUrl + historyPaginationKey + "/", true)
    //type, url, async
    params="site="+window.location.toString()
    console.log(params)
    sendSite.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    sendSite.setRequestHeader("Content-length", params.length )
    sendSite.setRequestHeader("Connection", "close")
    latestCommit.onreadystatechange = function() {
      console.log(sendSite.response)
      if(this.readyState === XMLHttpRequest.DONE && this.status === 200){
        //alert(sendSite.response)
      } else {
        //alert(sendSite.response)
      }
    }
    sendSite.send("site="+window.location.toString())
  }
}
latestCommit.send()


  
