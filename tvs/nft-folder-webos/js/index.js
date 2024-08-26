var eventRegister = (function () {
  var lastClickedId = null;
  var itemArray = document.getElementsByClassName("item");
  var updateText = function (query, value) {
    var element = document.querySelectorAll(query);
    if (element && element.length > 0) {
      element[0].innerText = value;
    }
  };
  var showXYCoordinates = function (details) {
    updateText("span.x_coor", details.pageX);
    updateText("span.y_coor", details.pageY);
  };
  var _onClickEvent = function (e) {
    if (lastClickedId) {
      document.getElementById(lastClickedId).classList.remove("clicked");
    }
    document.getElementById(e.target.id).classList.add("clicked");
    lastClickedId = e.target.id;
    updateText("p.ok_select", lastClickedId);

    showPlayer(); // TODO: dev tmp. play selected item, not a random one
  };

  var _onMouseOverEvent = function (e) {
    for (var i = 0; i < itemArray.length; i++) {
      _removeFocus(itemArray[i]);
    }
    document.getElementById(e.target.id).focus();
  };
  var _removeFocus = function (item) {
    item.blur();
  };
  var _itemKeyDownHandler = function (e) {
    if (e.keyCode === 13) {
      document.getElementById(e.target.id).classList.add("active");
    }
  };
  var _itemKeyUpHandler = function (e) {
    if (e.keyCode === 13) {
      document.getElementById(e.target.id).classList.remove("active");
      _onClickEvent(e);
    }
  };
  var _itemMouseOutHandler = function (e) {
    _removeFocus(document.getElementById(e.target.id));
  };
  var addEventListeners = function () {
    window.addEventListener("mouseover", showXYCoordinates);
    for (var i = 0; i < itemArray.length; i++) {
      itemArray[i].addEventListener("mouseover", _onMouseOverEvent);
      itemArray[i].addEventListener("mouseout", _itemMouseOutHandler);
      itemArray[i].addEventListener("click", _onClickEvent);
      itemArray[i].addEventListener("keyup", _itemKeyUpHandler);
      itemArray[i].addEventListener("keydown", _itemKeyDownHandler);
    }
  };
  var cursorVisibilityChange = function (event) {
    var visibility = event.detail.visibility;
    if (visibility) {
      console.log("Cursor appeared");
    } else {
      console.log("Cursor disappeared");
      updateText("span.x_coor", "-");
      updateText("span.y_coor", "-");
    }
  };
  var keyEventHandler = function (event) {
    var keyCode = event.keyCode;
    var type = event.type;
    var key = event.key || event.keyIdentifier;

    if (key) {
      updateText("span.key_name", key);
      updateText("span.key_code", keyCode);
      updateText("span.key_status", type);
    }
    //cursor hide for webOS 1.x
    if (type === "keydown" && keyCode === 1537) {
      console.log(type + "  " + keyCode + "  " + key);
      updateText("span.x_coor", "-");
      updateText("span.y_coor", "-");
    }
  };
  return {
    addEventListeners,
    cursorVisibilityChange,
    keyEventHandler,
  };
})();

window.addEventListener("load", function () {
  SpatialNavigation.init();
  SpatialNavigation.add({
    selector: ".item",
  });
  SpatialNavigation.makeFocusable();
  eventRegister.addEventListeners();
  document.addEventListener(
    "cursorStateChange",
    eventRegister.cursorVisibilityChange,
    false
  );
  document.addEventListener("keydown", eventRegister.keyEventHandler, false);
  document.addEventListener("keyup", eventRegister.keyEventHandler, false);
});

// TODO: merge the code above with the code below

document.addEventListener(
  "webOSLaunch",
  function (inData) {
    console.log("webOSLaunch");
  },
  true
);

document.addEventListener(
  "webOSRelaunch",
  function (inData) {
    console.log("webOSRelaunch");
  },
  true
);

var hidden, visibilityChange;
if (typeof document.hidden !== "undefined") {
  hidden = "hidden";
  visibilityChange = "visibilitychange";
} else if (typeof document.webkitHidden !== "undefined") {
  hidden = "webkitHidden";
  visibilityChange = "webkitvisibilitychange";
}

document.addEventListener(
  visibilityChange,
  function () {
    if (document[hidden]) {
      removePlayer();
    }
  },
  true
);

function updateIframeContent() {
  var iframe = document.getElementById("generativePlayerFrame");
  if (iframe) {
    fetchHtml("sample") // TODO: pass item
      .then((content) => {
        if (content) {
          iframe.srcdoc = content;
        }
      });
  }
}

function removePlayer() {
  var iframe = document.getElementById("generativePlayerFrame");
  isShowingPlayer = false;
  if (iframe) {
    iframe.remove();
  }
}

var isShowingPlayer = false;

function showPlayer() {
  // TODO: if showing player again after it was hidden, make sure to start with the same item
  if (isShowingPlayer) {
    return;
  }
  if (document[hidden]) {
    return;
  }
  var iframe = document.createElement("iframe");
  isShowingPlayer = true;
  iframe.id = "generativePlayerFrame";
  document.body.appendChild(iframe);
  updateIframeContent();
}

document.addEventListener(
  "keydown",
  function (event) {
    console.log("keydown", event.keyCode);
    // 37 left
    // 39 right
    // 13 center
    // 38 top
    // 40 bottom
    // 413 stop
    // 415 play
    // 19 pause
    // 412 back
    // 417 forward
    updateIframeContent(); // TODO: different updates for different keys
  },
  false
);

async function fetchHtml(notUsedYetItem) {
  // TODO: use passed item or stop passing it at all

  const itemsJsonString = await readFileContent("assets/items.json");
  let items;
  try {
    items = JSON.parse(itemsJsonString);
  } catch (error) {
    return null;
  }

  if (!Array.isArray(items) || items.length === 0) {
    return null;
  }

  const random = Math.floor(Math.random() * items.length);
  const item = items[random];

  let htmlContent;
  try {
    htmlContent = await generateHtmlContent(item);
  } catch (error) {
    return null;
  }

  return htmlContent.html;
}

const filePromises = new Map();

function readFileContent(filePath) {
  if (!filePromises.has(filePath)) {
    filePromises.set(filePath, loadFile(filePath));
  }
  return filePromises.get(filePath);
}

function loadFile(filePath) {
  return new Promise((resolve, reject) => {
    const iframe = document.createElement("iframe");
    iframe.style.display = "none";
    iframe.src = filePath;
    document.body.appendChild(iframe);

    iframe.onload = function () {
      try {
        const content =
          iframe.contentDocument.body.textContent ||
          iframe.contentDocument.body.innerText;
        resolve(content);
      } catch (error) {
      } finally {
        document.body.removeChild(iframe);
        filePromises.delete(filePath);
      }
    };

    iframe.onerror = function () {
      document.body.removeChild(iframe);
      filePromises.delete(filePath);
    };
  });
}

async function generateHtmlContent(item) {
  const id = item.address + item.abId;

  const tokensJsonString = await readFileContent(`assets/tokens/${id}.json`);
  const bundledTokens = JSON.parse(tokensJsonString);

  const scriptJsonString = await readFileContent(`assets/scripts/${id}.json`);
  const script = JSON.parse(scriptJsonString);

  const lib =
    script.kind === "js" || script.kind === "svg"
      ? ""
      : await readFileContent(`assets/libs/${script.kind}.js`);

  const random = Math.floor(Math.random() * bundledTokens.items.length);
  const token = bundledTokens.items[random];
  const hash = token.hash;
  const tokenid = token.id;

  let tokenData;
  if (script.address === "0x059edd72cd353df5106d2b9cc5ab83a52287ac3a") {
    tokenData = `let tokenData = {"tokenId": "${tokenid}", "hashes": ["${hash}"]}`;
  } else {
    tokenData = `let tokenData = {"tokenId": "${tokenid}", "hash": "${hash}"}`;
  }

  const viewport =
    '<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"/>';

  let html;
  switch (script.kind) {
    case "svg":
      html = `
                <html>
                <head>
                  ${viewport}
                  <meta charset="utf-8">
                  <style type="text/css">
                    body {
                      min-height: 100%;
                      margin: 0;
                      padding: 0;
                    }
                    svg {
                      padding: 0;
                      margin: auto;
                      display: block;
                      position: absolute;
                      top: 0;
                      bottom: 0;
                      left: 0;
                      right: 0;
                    }
                  </style>
                </head>
                <body></body>
                <script>${tokenData}</script>
                <script>${script.value}</script>
                </html>
            `;
      break;
    case "js":
      html = `
                <html>
                <head>
                  ${viewport}
                  <meta charset="utf-8">
                  <script>${tokenData}</script>
                  <style type="text/css">
                    body {
                      margin: 0;
                      padding: 0;
                    }
                    canvas {
                      padding: 0;
                      margin: auto;
                      display: block;
                      position: absolute;
                      top: 0;
                      bottom: 0;
                      left: 0;
                      right: 0;
                    }
                  </style>
                </head>
                <body>
                  <canvas></canvas>
                  <script>${script.value}</script>
                </body>
                </html>
            `;
      break;
    case "p5js100":
    case "p5js190":
      html = `
                <html>
                <head>
                  ${viewport}
                  <meta charset="utf-8">
                  <script>${lib}</script>
                  <script>${tokenData}</script>
                  <script>${script.value}</script>
                  <style type="text/css">
                    html {
                      height: 100%;
                    }
                    body {
                      min-height: 100%;
                      margin: 0;
                      padding: 0;
                    }
                    canvas {
                      padding: 0;
                      margin: auto;
                      display: block;
                      position: absolute;
                      top: 0;
                      bottom: 0;
                      left: 0;
                      right: 0;
                    }
                  </style>
                </head>
                </html>
            `;
      break;
    case "paper":
    case "twemoji":
      html = `
                <html>
                <head>
                  ${viewport}
                  <meta charset="utf-8"/>
                  <script>${lib}</script>
                  <script>${tokenData}</script>
                  <script>${script.value}</script>
                  <style type="text/css">
                    html {
                      height: 100%;
                    }
                    body {
                      min-height: 100%;
                      margin: 0;
                      padding: 0;
                    }
                    canvas {
                      padding: 0;
                      margin: auto;
                      display: block;
                      position: absolute;
                      top: 0;
                      bottom: 0;
                      left: 0;
                      right: 0;
                    }
                  </style>
                </head>
                </html>
            `;
      break;
    case "three":
      html = `
                <html>
                <head>
                  ${viewport}
                  <script>${lib}</script>
                  <meta charset="utf-8">
                  <style type="text/css">
                    body {
                      margin: 0;
                      padding: 0;
                    }
                    canvas {
                      padding: 0;
                      margin: auto;
                      display: block;
                      position: absolute;
                      top: 0;
                      bottom: 0;
                      left: 0;
                      right: 0;
                    }
                  </style>
                </head>
                <body></body>
                <script>${tokenData}</script>
                <script>${script.value}</script>
                </html>
            `;
      break;
    case "regl":
      html = `
                <html>
                <head>
                  ${viewport}
                  <script>${lib}</script>
                  <script>${tokenData}</script>
                  <meta charset="utf-8">
                  <style type="text/css">
                    body {
                      margin: 0;
                      padding: 0;
                    }
                    canvas {
                      padding: 0;
                      margin: auto;
                      display: block;
                      position: absolute;
                      top: 0;
                      bottom: 0;
                      left: 0;
                      right: 0;
                    }
                  </style>
                </head>
                <body>
                  <script>${script.value}</script>
                </body>
                </html>
            `;
      break;
    case "tone":
      html = `
                <html>
                <head>
                  ${viewport}
                  <script>${lib}</script>
                  <meta charset="utf-8">
                  <style type="text/css">
                    body {
                      margin: 0;
                      padding: 0;
                    }
                    canvas {
                      padding: 0;
                      margin: auto;
                      display: block;
                      position: absolute;
                      top: 0;
                      bottom: 0;
                      left: 0;
                      right: 0;
                    }
                  </style>
                </head>
                <body>
                  <canvas></canvas>
                </body>
                <script>${tokenData}</script>
                <script>${script.value}</script>
                </html>
            `;
      break;
    default:
      html = "<html><body>hmm</body></html>";
  }
  return {
    html: html,
    tokenId: tokenid,
  };
}
