const ShrestyJS = {};
ShrestyJS.currentPageId = 'home';
ShrestyJS.user = '';
ShrestyJS.password = '';
ShrestyJS.loggerON = true;
ShrestyJS.credentials = ''; // = anonymous:anonymous in base64 - Basic YW5vbnltb3VzOmFub255bW91cw==

ShrestyJS.log = (...data) => {
    if ( ShrestyJS.loggerON ) {
        console.log(...data);
    }
}

ShrestyJS.warn = (...data) => {
    if ( ShrestyJS.loggerON ) {
        console.warn(...data);
    }
}

ShrestyJS.findDiff = (str1, str2) => { 
    let diff= "";
    str2.split('').forEach(function(val, i){
        if (val != str1.charAt(i))
            diff += val ;         
    });
    return diff;
}

ShrestyJS.stringify = (obj = [{}]) => {
    let res;
    if ( typeof obj === "object" ) {
        res = JSON.stringify(obj, null, 2);
    } else {
        res = obj;
    }
    return res;
}

ShrestyJS.parse = (str = "[{}]") => {
    let res;
    try {
        res = JSON.parse(str);
    } catch( err ) {
        ShrestyJS.log("Response:\n" + str + "\nis not JSON parsable:\n" + err); // error in the above string (in this case, yes)!
        res = str;
    }
    return res;
}

ShrestyJS.loginToElem = (user, password, returnElem) => {
    ShrestyJS.user = user;
    ShrestyJS.password = password;
    //ShrestyJS.credentials = "Basic " + window.btoa( user + ":" + password );
    let resFunc = (response) => {
        ShrestyJS.log("LOGIN result", response[0]['result']);
        if( typeof response[0]['result'] == 'undefined' ) {
            returnElem.innerHTML = "Could not login";
        } else {
            returnElem.innerHTML = response[0]['result'];
            setTimeout( () => { returnElem.innerHTML = ""; }, 5000 );
        }
    };
    ShrestyJS.requestToFunction("SELECT 'logged in' AS result", resFunc);
}

ShrestyJS.readCredentialsFromAuthorizationHeader = (authHeader) => {
    let cred = ["anonymous", "anonymous"]; // standard
    if ( typeof authHeader == 'string' ) { //&& ShrestyJS.user == ''
        cred = window.atob(authHeader.substring(6)).split(":");
        ShrestyJS.log( "reading 'cred' from authHeader", cred );
    } else if ( ShrestyJS.credentials != '' ) {
        cred = window.atob(ShrestyJS.credentials.substring(6)).split(":");
        ShrestyJS.log( "reading 'cred' from credentials", cred );
    }
    ShrestyJS.user = cred[0];
    ShrestyJS.password = cred[1];
}

ShrestyJS.requestToFunction = (EXEC, returnFunc = function(response){return response}) => {
    const HttpPG = new XMLHttpRequest();
    const url = '/exec/' + encodeURI(EXEC);
    HttpPG.open("POST", url);
    //ShrestyJS.readCredentialsFromAuthorizationHeader();
    HttpPG.setRequestHeader("Request-User", ShrestyJS.user);
    HttpPG.setRequestHeader("Request-Password", ShrestyJS.password);
    HttpPG.send();
    HttpPG.onreadystatechange = (ev) => {
        if ( HttpPG.readyState == 4 && HttpPG.status > 0 && HttpPG.responseText ) { // if really ready with request
            ShrestyJS.log("Event: ", ev);
            ShrestyJS.log("ShrestyResponseText: ", HttpPG.responseText);
            // reading the authorization header from basic auth done by user
            if ( HttpPG.getResponseHeader("Authorization") != null ) {
                ShrestyJS.log("Header Authorization", HttpPG.getResponseHeader("Authorization"));
                ShrestyJS.readCredentialsFromAuthorizationHeader(HttpPG.getResponseHeader("Authorization"));
            }
            returnFunc(HttpPG.responseText);
        }
    }
}

ShrestyJS.requestToElem = (EXEC, returnElem, loggerON ) => {
    ShrestyJS.requestToFunction(EXEC, (response) => {
        returnElem.innerHTML = ShrestyJS.stringify(response);
    }, loggerON )
}

ShrestyJS.registerRespondToElem = (user, password, returnElem) => {
    ShrestyJS.requestToFunction("SELECT create_user_minimal('"+user+"', '"+password+"')", (response) => {
        if ( response[0]['create_user_minimal'] == true ) {
            returnElem.innerHTML = "Registerd: "+user;
            setTimeout( () => { returnElem.innerHTML = ""; }, 5000 );
        } else {
            returnElem.innerHTML = ShrestyJS.stringify(response);
        }
    }, loggerON)
}

ShrestyJS.showPage = (elemToShowById = "home") => {
    document.getElementById(ShrestyJS.currentPageId).style.display = "none";
    ShrestyJS.currentPageId = elemToShowById;
    document.getElementById(ShrestyJS.currentPageId).style.display = "block";
}

ShrestyJS.createPageSwitchers = (selection = "header nav a", linkSelector = "href") => {
    let list = document.querySelectorAll(selection);
    let listLength = list.length;
    for (let i = 0; i < listLength; i++) {
        list[i].addEventListener("click", function(ev){
            ev.preventDefault();
            const page = ev.srcElement.getAttribute(linkSelector);
            ShrestyJS.log( "Navigating to #"+page ); 
            ShrestyJS.showPage( page );
            const nextState = { additionalInformation: 'ShrestyJS updated the URL' };
            // This will replace the current entry in the browser's history, without reloading
            window.history.replaceState(nextState, "Shresty - "+page, "#"+page);
        });
    }
}

ShrestyJS.goPage = () => {
    let currentPage = ShrestyJS.currentPageId;
    if ( window.location.hash.length > 0 ){ 
        currentPage = window.location.hash.substring(1);
    }
    ShrestyJS.showPage(currentPage); 
}
document.addEventListener("DOMContentLoaded", function(event) {
    ShrestyJS.goPage();
});

ShrestyJS.onConfirmRefresh = (event) => {
  event.preventDefault();
  return event.returnValue = "Are you sure you want to leave the page?\nYou will loose the connection with user/password and need to re-enter.";
}
window.addEventListener("beforeunload", ShrestyJS.onConfirmRefresh, { capture: true });
