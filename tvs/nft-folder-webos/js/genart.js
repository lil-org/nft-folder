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
  