class Random {
    constructor() {
        this.useA = false;
        let sfc32 = function(uint128Hex) {
            let a = parseInt(uint128Hex.substr(0, 8), 16);
            let b = parseInt(uint128Hex.substr(8, 8), 16);
            let c = parseInt(uint128Hex.substr(16, 8), 16);
            let d = parseInt(uint128Hex.substr(24, 8), 16);
            return function() {
                a |= 0;
                b |= 0;
                c |= 0;
                d |= 0;
                let t = (((a + b) | 0) + d) | 0;
                d = (d + 1) | 0;
                a = b ^ (b >>> 9);
                b = (c + (c << 3)) | 0;
                c = (c << 21) | (c >>> 11);
                c = (c + t) | 0;
                return (t >>> 0) / 4294967296;
            };
        };
        this.prngA = new sfc32(tokenData.hash.substr(2, 32));
        this.prngB = new sfc32(tokenData.hash.substr(34, 32));
        for (let i = 0; i < 1e6; i += 2) {
            this.prngA();
            this.prngB();
        }
    }
    random_dec() {
        this.useA = !this.useA;
        return this.useA ? this.prngA() : this.prngB();
    }
    random_num(a, b) {
        return a + (b - a) * this.random_dec();
    }

    random_int(a, b) {
        return Math.floor(this.random_num(a, b + 1));
    }

    random_choice(list) {
        return list[this.random_int(0, list.length - 1)];
    }
}

let R, rnd, rint, choice, sn, rexp, rtri, wPick;
let W, H, vec;
let canvas,
    PPI = 96;
let MM = PPI / 25.4;
const MAX_THREAD_NUMBER = 15;


function setupRandom() {
    R = new Random();
}


function saveMyPNG() {
    save(canvas, `${tokenData.tokenId}.png`);
}


function saveMySVG(width_mm, height_mm) {
    let polyColors = new Set(polys.map((p) => p.sc.toString()));
    if (polyColors.size > MAX_THREAD_NUMBER) throw "too many colors";

    let svgcanvas = createSVGCanvas(width_mm, height_mm, true);

    saveSVGElement(svgcanvas, `${tokenData.tokenId}.svg`);
}


function saveSVGElement(svgElement, name) {
    svgElement.setAttribute("xmlns", "http://www.w3.org/2000/svg");
    var svgData = svgElement.outerHTML;
    var preface = '<?xml version="1.0" standalone="no"?>\r\n';
    var svgBlob = new Blob([preface, svgData], {
        type: "image/svg+xml;charset=utf-8",
    });
    var svgUrl = URL.createObjectURL(svgBlob);
    var downloadLink = document.createElement("a");
    downloadLink.href = svgUrl;
    downloadLink.download = name;
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
    return svgElement
}


function createSVGCanvas(width_mm, height_mm, localSave) {
    console.log(width_mm, height_mm);
    ns = "http://www.w3.org/2000/svg";
    svg = document.createElementNS(ns, "svg");
    groups = [];


    svg.setAttribute("version", "1.1");
    svg.setAttribute("xmlns:xlink", "http://www.w3.org/2000/xlink");
    svg.setAttribute("width", "100vw");
    svg.setAttribute("height", "100vh");
    svg.setAttribute("viewBox", "0 0 " + width_mm + " " + height_mm);


    let layers = {};
    let layer;

    let colorsUsed = new Set();
    polys.forEach((x) => colorsUsed.add(x.sc));

    let borderColorsUsed = new Set();
    bPolys.forEach((x) => borderColorsUsed.add(x.sc));


    //create underlayment layer
    layerName = colors[14].color;
    layer = document.createElementNS(ns, "g");
    layer.setAttribute("id", layerName.replaceAll(",", ""));
    layer.setAttribute("style", `fill:none;stroke-width:1;stroke:rgb(${colors[14].rgb});`);
    svg.appendChild(layer);
    layers[layerName.replaceAll(",", "")] = layer;


    let newPath = document.createElementNS(ns, "path");
    let d = `M ${1} ${1} L ${width_mm-1} ${1} L ${width_mm-1} ${height_mm-1} L ${1} ${height_mm-1} L ${1} ${1}`;
    newPath.setAttribute("d", d);
    layer.appendChild(newPath);



    //create infill layers
    for (let i = 0; i < colors.length - 1; i++) {
        layerName = colors[i].color;
        layer = document.createElementNS(ns, "g");
        layer.setAttribute("id", layerName.replaceAll(",", ""));
        layer.setAttribute("style", `fill:none;stroke-width:1;stroke:rgb(${colors[i].rgb});`);

        svg.appendChild(layer);
        layers[layerName.replaceAll(",", "")] = layer;

        // if no stitches in that layer, add a ghost stitch to make sure it's recognized by machine for ordering purposes 
        if (!colorsUsed.has(colors[i].rgb)) {
            let newPath = document.createElementNS(ns, "path");
            let d = `M ${vertices[0][0][0]} ${vertices[0][0][1]} L ${vertices[0][0][0]+1} ${vertices[0][0][1]+1}`;
            newPath.setAttribute("d", d);
            layer.appendChild(newPath);
        }
    }

    ///put navy border first
    layerName = colors[14].color + "b";
    layer = document.createElementNS(ns, "g");
    layer.setAttribute("id", layerName.replaceAll(",", ""));
    layer.setAttribute("style", `fill:none;stroke-width:1;stroke:rgb(${colors[14].rgb});`);

    svg.appendChild(layer);
    layers[layerName.replaceAll(",", "")] = layer;
    // if no stitches in that layer, add a ghost stitch to make sure it's recognized by machine for ordering purposes 
    if (!borderColorsUsed.has(colors[14].rgb)) {
        let newPath = document.createElementNS(ns, "path");
        let d = `M ${vertices[0][0][0]} ${vertices[0][0][1]} L ${vertices[0][0][0]+1} ${vertices[0][0][1]+1}`;
        newPath.setAttribute("d", d);
        layer.appendChild(newPath);
    }

    //create border layers (after navy)
    for (let i = 0; i < colors.length - 1; i++) {
        layerName = colors[i].color + "b";
        layer = document.createElementNS(ns, "g");
        layer.setAttribute("id", layerName.replaceAll(",", ""));
        layer.setAttribute("style", `fill:none;stroke-width:1;stroke:rgb(${colors[i].rgb});`);

        svg.appendChild(layer);
        layers[layerName.replaceAll(",", "")] = layer;
        // if no stitches in that layer, add a ghost stitch to make sure it's recognized by machine for ordering purposes 
        if (!borderColorsUsed.has(colors[i].rgb)) {
            let newPath = document.createElementNS(ns, "path");
            let d = `M ${vertices[0][0][0]} ${vertices[0][0][1]} L ${vertices[0][0][0]+1} ${vertices[0][0][1]+1}`;
            newPath.setAttribute("d", d);
            layer.appendChild(newPath);
        }
    }



    //populate layers
    polys.map((p) => {
        let c = p.sc.toString();
        let cl = colors.find(item => item.rgb === p.sc);

        let path = p.shape;
        let newPath = document.createElementNS(ns, "path");
        let d = `M ${path[0].x} ${path[0].y} `;
        for (let i = 1; i < path.length; i++) {
            d += `L ${path[i].x} ${path[i].y} `;
        }
        newPath.setAttribute("d", d);
        layers[cl.color].appendChild(newPath);
    });

    bPolys.map((p) => {
        let c = p.sc.toString();
        let cl = colors.find(item => item.rgb === p.sc);

        let path = p.shape;
        let newPath = document.createElementNS(ns, "path");
        let d = `M ${path[0].x} ${path[0].y} `;
        for (let i = 1; i < path.length; i++) {
            d += `L ${path[i].x} ${path[i].y} `;
        }
        newPath.setAttribute("d", d);

        layers[cl.color + "b"].appendChild(newPath);
    });

    if (localSave) {
        return svg;
    } else {
        return svg.outerHTML;
    }
}



function getKeyByValue(object, value) {
    return Object.keys(object).find(key =>
        object[key] === value);
}

class Poly {
    constructor(
        shape,
        x = 0,
        y = 0,
        s = 1,
        r = 0,
        closed = true,
        sc = undefined,
        c = undefined
    ) {
        this.shape = shape.map((v) => {
            let cv = v.copy();
            let rv = cv.rotate(r);
            return createVector(x + rv.x * s, y + rv.y * s);
        });
        if (closed) {
            this.shape.push(this.shape[0].copy());
        }
        this.sc = sc
        if (sc == undefined) this.sc = color(0);
        this.c = c;
    }

    reverse() {
        let shape = [];
        for (let i = this.shape.length - 1; i >= 0; i--) {
            shape.push(this.shape[i]);
        }
        this.shape = shape;
        return this;
    }

    copy(x = undefined, y = undefined, s = 1, c = undefined, sc = undefined) {
        if (x == undefined) x = 0
        if (y == undefined) y = 0
        if (s == undefined) s = 1
        if (c == undefined) c = this.c
        if (sc == undefined) sc = this.sc
        return new Poly(this.shape, x, y, s, 0, this.closed, sc, c);
    }


    setColorValue(v) {
        this.colorValue = v;
        return this;
    }


    setOrderValue(v) {
        this.orderValue = v;
        return this;
    }


    setColor(sc = undefined, c = undefined) {
        this.sc = sc;
        this.c = c;
        return this;
    }


}let vertices = [];
let polys = [];
let bPolys = [];
let frCount = 0;
let noiseAlpha = 0;
let embroiderySizeW = 3 * PPI;
let embroiderySizeH = PPI;
let colorStyleOptions = [{
        name: "alternating",
        weight: 3
    },
    {
        name: "allSolidGrad",
        weight: 3
    },
    {
        name: "allSolidRandom",
        weight: 3
    },
    {
        name: "allSolid",
        weight: 2
    },
    {
        name: "allSolidGreyWhite",
        weight: 2
    },
    {
        name: "longGrad",
        weight: 4
    },
    {
        name: "shortGrad",
        weight: 4
    },
    {
        name: "hyper",
        weight: 1
    },
    {
        name: "patchwork",
        weight: 3
    },
    {
        name: "splitTwo",
        weight: 2
    },
    {
        name: "splitAll",
        weight: 4
    },
    {
        name: "biColorGrad",
        weight: 5
    }
];
let colorStyle = [];
for (let i in colorStyleOptions) {
    for (let s = 0; s < colorStyleOptions[i].weight; s++) {
        colorStyle.push(colorStyleOptions[i].name)
    }
}

let borderStyle = ["allWhite", "allGrey", "allNavy", "gradient", "random", "singleColor"];
let numSlashes;
let slashInsideColors = [];
let slashBorderColors = [];
let slashOrientations = [];
let slashpWs = [];
let startColor;
let borderStartColor;
let totalFillStitchCount = 0;
let globalSpread;
let globalSpeed;
let randomColorA;
let randomColorB;
let hyperType;
let hyperAll;
let translateValue;
let totalWidth = 0;
let pGramHeightInMM = 19;
let pH = pGramHeightInMM * MM;
let angle;
let arrow;
let totalCount = 0;
let lnOrientation;
let scaler;
let switchScaler;
let partyMode;
let noiseMode;
let outlineMode=false;
let finishLine=false;
let lonely = false;
let forPrint = false;
let activeFillLine = [];
let slashFrames = [];

//parallelogram spacing
let pS = 18;

let fillStitchLengthInMM = 1;
let underlaymentStitchLengthInMM = 2;
let underlaymentSpacingInMM = 1.5;
let LineSpacingInMM = 0.35;
let backgroundColor = 255;

///// THREAD COLOR ORDER /////
///// 1 navy (underlayment)
///// 2 red
///// 3 pink
///// 4 magenta
///// 5 purple
///// 6 dark blue
///// 7 blue
///// 8 green
///// 9 light green
///// 10 chartreuse
///// 11 yellow
///// 12 light orange
///// 13 orange
///// 14 white
///// 15 grey
///////////////////////////////



let colors = [{
        color: "red",
        val: 0,
        rgb: [255, 23, 0],
        orderValue: 0
    },
    {
        color: "magenta",
        val: 1,
        rgb: [255, 0, 211],
        orderValue: 0
    },
    {
        color: "purple",
        val: 2,
        rgb: [154, 0, 255],
        orderValue: 0
    },
    {
        color: "blue",
        val: 3,
        rgb: [18, 0, 255],
        orderValue: 0
    },
    {
        color: "lightblue",
        val: 4,
        rgb: [0, 191, 255],
        orderValue: 0
    },
    {
        color: "aqua",
        val: 5,
        rgb: [0, 255, 205],
        orderValue: 0
    },
    {
        color: "green",
        val: 6,
        rgb: [0, 255, 88],
        orderValue: 0
    },
    {
        color: "chartreuse",
        val: 7,
        rgb: [205, 255, 0],
        orderValue: 0
    },
    {
        color: "yellow",
        val: 8,
        rgb: [255, 248, 0],
        orderValue: 0
    },
    {
        color: "marigold",
        val: 9,
        rgb: [255, 210, 0],
        orderValue: 0
    },
    {
        color: "orange",
        val: 10,
        rgb: [255, 165, 0],
        orderValue: 0
    },
    {
        color: "darkorange",
        val: 11,
        rgb: [255, 119, 0],
        orderValue: 0
    },
    {
        color: "white",
        val: 12,
        rgb: [255, 255, 255],
        orderValue: 0
    },
    {
        color: "grey",
        val: 13,
        rgb: [125, 125, 125],
        orderValue: 0
    },
    {
        color: "navy",
        val: 14,
        rgb: [42, 40, 116],
        orderValue: 0
    },

]



function presetup() {
    canvas = createCanvas(window.windowWidth, window.windowHeight)

    setupRandom()
    noFill()

}

function setup() {
    presetup();
    background(255);
    arrow = R.random_choice([true, false]);

    angle = arrow ? radians(R.random_choice([25, 25, 25, 25, 50, 50, 50, 50])) : radians(R.random_choice([0, 25, 25, 25, 25, 50, 50, 50, 50]));


    colorStyle = R.random_choice(colorStyle);
    borderStyle = R.random_choice(borderStyle);
    if (colorStyle == "hyper") {
        hyperType = R.random_int(0, 1);
        hyperSingle = R.random_int(0, 1);
        if (hyperSingle) hyperSingle = R.random_int(1, vertices.length);
    }



    lnOrientation = (colorStyle == "biColorGrad" || arrow) ? "v" : R.random_choice(["h", "v"]);

    let smallerDim = Math.min(width, height) == width ? width : height;
    scaler = smallerDim / (smallerDim == width ? embroiderySizeW : embroiderySizeH * 2);

    let w = 0;

    let s = 0;
    while (w < embroiderySizeW) {
        let slashWidth = R.random_choice([20, 25, 30, 35]);
        let pGram = drawParallelogram(0, pH + (embroiderySizeH - pH) / 2, slashWidth, pH, angle);
        let v1 = createVector(pGram[1][0], pGram[1][1]);
        let v2 = createVector(pGram[2][0], pGram[2][1]);
        let midPoint = p5.Vector.lerp(v1, v2, 0.5);
        let totalSlashWidth = arrow ? midPoint.x - pGram[3][0] : pGram[1][0] - pGram[3][0];
        if (s == 0) {
            w = totalSlashWidth + pS;
        } else if (w + slashWidth + pS < embroiderySizeW) {
            w = w + slashWidth + pS;
        } else {
            break;
        }
        vertices.push(pGram);
        s++;
    }
    numSlashes = vertices.length;
    for (let s = 0; s < numSlashes; s++) {
        activeFillLine.push(R.random_int(0, 99));
        slashFrames.push(0);
    }
    translateValue = ((embroiderySizeW - w + pS) / 2);

    //global color generation here
    globalSpread = R.random_int(3, 20);
    globalSpeed = R.random_int(0, 3);
    startColor = R.random_int(0, 11);
    borderStartColor = R.random_int(0, 11);
    randomColorA = colorStyle == "biColorGrad" ? R.random_int(0, 13) : colorStyle == "allSolidGreyWhite" ? R.random_int(12, 13) : R.random_int(0, 11);
    randomColorB = colorStyle == "biColorGrad" ? R.random_int(0, 13) : colorStyle == "allSolidGreyWhite" ? R.random_int(12, 13) : R.random_int(0, 11);

    while (randomColorB == randomColorA) {
        randomColorB = colorStyle == "allSolidGreyWhite" ? R.random_int(12, 13) : R.random_int(0, 11);
    }



    for (let slash = 0; slash < vertices.length; slash++) {
        let thisOrientation = R.random_choice(["h", "v"]);
        slashOrientations.push(thisOrientation);

        let pW = vertices[slash][1][0] - vertices[slash][0][0];
        slashpWs.push(pW);



        //outline
        let borderColor;
        if (borderStyle == "allWhite") {
            borderColor = 12;
        } else if (borderStyle == "allGrey") {
            borderColor = 13;
        } else if (borderStyle == "allNavy") {
            borderColor = 14;
        } else if (borderStyle == "random") {
            borderColor = R.random_int(0, 11);
        } else if (borderStyle == "gradient") {
            borderColor = (borderStartColor + slash) % colors.slice(0, 12).length;
        } else if (borderStyle == "singleColor") {
            borderColor = borderStartColor;
        } else {
            borderColor = 0;
        }
        slashBorderColors.push(borderColor);

        if (arrow) {
            drawStitchedBorderLine([vertices[slash][3][0], vertices[slash][0][1]], [vertices[slash][2][0], vertices[slash][0][1]], LineSpacingInMM, "h", 7, borderColor); /// arrow test
        } else {
            drawStitchedBorderLine(vertices[slash][0], vertices[slash][1], LineSpacingInMM, "h", 7, borderColor);
        }
        drawStitchedBorderLine(vertices[slash][1], vertices[slash][2], LineSpacingInMM, "v", 7, borderColor, arrow);
        drawStitchedBorderLine(vertices[slash][2], vertices[slash][3], LineSpacingInMM, "h", 7, borderColor);
        drawStitchedBorderLine(vertices[slash][3], vertices[slash][0], LineSpacingInMM, "v", 7, borderColor, arrow);


        //inside
        drawStitchedFillLines(vertices[slash][0], vertices[slash][1], vertices[slash][2], vertices[slash][3], LineSpacingInMM, (lnOrientation == "mix" ? thisOrientation : lnOrientation), slash, (arrow && angle != radians(0)));


        //underlayment
        drawUnderlayment(vertices[slash][0], vertices[slash][1], vertices[slash][2], vertices[slash][3], (lnOrientation == "mix" ? thisOrientation : lnOrientation), 14, arrow);




        totalWidth = totalWidth + pW + pS;
        partyMode = false;
        noiseMode = true;
    }



    for (let i in polys) {
        if (polys[i].colorValue == 14) {
            polys[i].setColor(colors[14].rgb);
        }
    }

    for (let a = 0; a < 14; a++) {

        for (let i in polys) {
            if (polys[i].colorValue == a) {
                polys[i].setColor(colors[a].rgb);
            }
        }
    }

    for (let a = 0; a < 15; a++) {

        for (let i in bPolys) {
            if (bPolys[i].colorValue == a) {
                bPolys[i].setColor(colors[a].rgb);
            }
        }
    }

}function draw() {
    background(backgroundColor);
   
    translate(width / 2 - embroiderySizeW / 2 * scaler, (lonely||forPrint)?(height / 1.3 - embroiderySizeH / 2 * scaler):height / 2 - embroiderySizeH / 2 * scaler);
    scale(scaler);
    totalWidth = 0;
    totalCount = 0;
    
    for (let slash = 0; slash < vertices.length; slash++) {
        if (!outlineMode){
        drawFillLines(vertices[slash][0], vertices[slash][1], vertices[slash][2], vertices[slash][3], LineSpacingInMM, (lnOrientation == "mix" ? thisOrientation : lnOrientation), slash, (arrow && angle != radians(0)));
        }
        for (let z = 10; z > 0; z--) {
            strokeWeight(z / 4);
            let col = outlineMode?(backgroundColor==255?0:255):shadeColor(colors[slashBorderColors[slash]].rgb, -z)
            stroke(col);
            drawArrowBorder(slash);

        }
        
        totalWidth = totalWidth + slashpWs[slash] + pS;
    }
    frCount++;
    
}



function drawStitchedBorderLine(a, b, spacing, lineOrientation, stitchLength, color, arrow) {
    let counter = 0;
    let stitchSpacingInMM = spacing;
    let stitchSpacing = stitchSpacingInMM * MM;
    let lineDistX = Math.abs(a[0] - b[0]);
    let lineDistY = Math.abs(a[1] - b[1]);
    let totalStitches = Math.floor((lineOrientation == "h" ? lineDistX : lineDistY) / stitchSpacing);
    let spaceBetweenStitches = (lineOrientation == "h" ? lineDistX : lineDistY) / totalStitches;
    let increment = spaceBetweenStitches / (lineOrientation == "h" ? lineDistX : lineDistY);
    let connectedVectors = [];
    if (arrow) {
        for (let i = 0; i <= totalStitches; i++) {
            counter++;
            let v1 = createVector(a[0], a[1]);
            let v1b = createVector(b[0], a[1]);
            let v2 = createVector(b[0], b[1]);
            let midPoint = p5.Vector.lerp(v1, v2, 0.5);
            let pos;
            let nextPos;
            if (a[1] < b[1]) {
                pos = i < totalStitches / 2 ? p5.Vector.lerp(v1b, midPoint, i * increment * 2) : p5.Vector.lerp(v1, v2, i * increment);
                nextPos = i < totalStitches / 2 ? p5.Vector.lerp(v1b, midPoint, (i + 1) * increment * 2) : p5.Vector.lerp(v1, v2, (i + 1) * increment);
            } else {
                pos = i > totalStitches / 2 ? p5.Vector.lerp(v1b, midPoint, i * increment * 2) : p5.Vector.lerp(v1, v2, i * increment);
                nextPos = i > totalStitches / 2 ? p5.Vector.lerp(v1b, midPoint, (i + 1) * increment * 2) : p5.Vector.lerp(v1, v2, (i + 1) * increment);
            }
            let v3 = createVector(pos.x - stitchLength / 2 + totalWidth + translateValue - 2, pos.y);
            let v4 = createVector(pos.x + stitchLength / 2 + totalWidth + translateValue - 2, pos.y);
            if (counter % 2 == 0) {
                connectedVectors.push(v3);
                connectedVectors.push(v4);

            } else {
                connectedVectors.push(v4);
                connectedVectors.push(v3);

            }

        }
        let p1 = new Poly(connectedVectors, 0, 0, 1, 0, 0);
        p1.setColorValue(color);
        bPolys.push(p1);
    } else {
        for (let i = 0; i <= totalStitches; i++) {
            counter++;
            let v1 = createVector(a[0], a[1]);
            let v2 = createVector(b[0], b[1]);
            let pos = p5.Vector.lerp(v1, v2, i * increment);
            let nextPos = p5.Vector.lerp(v1, v2, (i + 1) * increment);
            let v3 = lineOrientation == "h" ? createVector(pos.x + totalWidth + translateValue, pos.y - stitchLength / 2) : createVector(pos.x - stitchLength / 2 + totalWidth + translateValue, pos.y);
            let v4 = lineOrientation == "h" ? createVector(pos.x + totalWidth + translateValue, pos.y + stitchLength / 2) : createVector(pos.x + stitchLength / 2 + totalWidth + translateValue, pos.y);
            if (counter % 2 == 0) {
                connectedVectors.push(v3);
                connectedVectors.push(v4);
            } else {
                connectedVectors.push(v4);
                connectedVectors.push(v3);
            }
        }
        let p1 = new Poly(connectedVectors, 0, 0, 1, 0, 0);
        p1.setColorValue(color);
        bPolys.push(p1);
    }

}
function drawStitchedFillLines(a, b, c, d, spacing, lineOrientation, slash, arrow) {
    let inset = 2;
    if (angle > 0 && lineOrientation == "h") spacing = spacing * (0.6 + angle);
    let stitchSpacingInMM = spacing;
    let stitchSpacing = stitchSpacingInMM * MM;
    let stitchLength = fillStitchLengthInMM * MM;
    let lineDistX = Math.abs(a[0] - b[0]);
    let lineDistY = Math.abs(a[1] - d[1]);
    let lineLength = (lineOrientation == "h" ? dist(a[0], a[1], d[0], d[1]) : lineDistX);
    let totalLinesToBeStitched = Math.floor((lineOrientation == "h" ? lineDistX : lineDistY) / stitchSpacing);
    let spaceBetweenLinesToBeStitched = (lineOrientation == "h" ? lineDistX : lineDistY) / totalLinesToBeStitched;
    let incrementA = spaceBetweenLinesToBeStitched / (lineOrientation == "h" ? lineDistX : lineDistY);
    let totalStitchesAcross = Math.floor(lineLength / stitchLength);
    let spaceBetweenStitches = lineLength / totalStitchesAcross;
    let incrementB = spaceBetweenStitches / lineLength;

    let thisFillStitchCount = 0;
    let localSpread = R.random_int(3, 20);
    let localSpreadSwitch = R.random_choice([true, false]);
    let slashSolidColor = R.random_int(0, 11);


    for (let i = 1; i <= totalLinesToBeStitched - 1; i++) {
        let col;

        //local color generation here
        if (colorStyle == "alternating") {
            col = slash % 2 == 0 ? randomColorA : randomColorB;
        } else if (colorStyle == "patchwork") {
            col = (startColor + Math.floor(totalFillStitchCount / (localSpreadSwitch ? localSpread : globalSpread))) % colors.slice(0, 12).length;
        } else if (colorStyle == "allSolidGrad") {
            col = (startColor + slash) % colors.slice(0, 12).length;
        } else if (colorStyle == "hyper") {
            if (!hyperSingle || (hyperSingle - 1) == slash) {
                col = hyperType == 0 ? R.random_int(0, 11) : (startColor + totalFillStitchCount) % colors.slice(0, 12).length;
            } else {
                col = slashSolidColor;
            }
        } else if (colorStyle == "allSolidRandom") {
            col = slashSolidColor;
        } else if (colorStyle == "longGrad") {
            col = (startColor + Math.floor(totalFillStitchCount / globalSpread) + R.random_int(0, 2)) % colors.slice(0, 12).length;
        } else if (colorStyle == "shortGrad") {
            col = (startColor + Math.floor(thisFillStitchCount / globalSpread) + R.random_int(0, 2)) % colors.slice(0, 12).length;
        } else if (colorStyle == "allSolid" || colorStyle == "allSolidGreyWhite") {
            col = randomColorA;
        } else if (colorStyle == "splitTwo") {
            if (i < totalLinesToBeStitched / 2) {
                col = slash % 2 == 0 ? randomColorA : randomColorB;
            } else {
                col = slash % 2 == 0 ? randomColorB : randomColorA;;
            }
        } else if (colorStyle == "splitAll") {
            if (i < totalLinesToBeStitched / 2) {
                col = slash % 2 == 0 ? (randomColorA + localSpread) % colors.slice(0, 12).length : (randomColorB + localSpread) % colors.slice(0, 12).length;
            } else {
                col = slash % 2 == 0 ? (randomColorB + localSpread) % colors.slice(0, 12).length : (randomColorA + localSpread) % colors.slice(0, 12).length;;
            }
        } else if (colorStyle == "biColorGrad") {
            let colorPicker = R.random_dec(0, 1);
            if (colorPicker < slash / (numSlashes - 1)) {
                col = randomColorA;
            } else {
                col = randomColorB;
            }
        } else {
            col = 13;
        }

        slashInsideColors.push(col);

        let thisRowA = [];

        colors[col].orderValue++;
        let v1 = createVector(a[0], a[1]);
        let v1b = createVector(d[0], a[1]);
        let v2 = lineOrientation == "h" ? createVector(b[0], b[1]) : createVector(d[0], d[1]);
        let midPointA = p5.Vector.lerp(v1, v2, 0.5);
        let v3 = lineOrientation == "h" ? createVector(d[0], d[1]) : createVector(b[0], b[1]);
        let v3b = createVector(c[0], b[1]);
        let v4 = createVector(c[0], c[1]);
        let midPointB = p5.Vector.lerp(v3, v4, 0.5);
        let posA = (i < totalLinesToBeStitched / 2 && arrow) ? p5.Vector.lerp(v1b, midPointA, i * incrementA * 2) : p5.Vector.lerp(v1, v2, i * incrementA);
        let posB = (i < totalLinesToBeStitched / 2 && arrow) ? p5.Vector.lerp(v3b, midPointB, i * incrementA * 2) : p5.Vector.lerp(v3, v4, i * incrementA);



        for (let j = 0; j < totalStitchesAcross; j++) {
            let v5 = lineOrientation == "h" ? createVector(posA.x + totalWidth + translateValue - (arrow ? 2 : 0), posA.y) : createVector(posA.x + totalWidth - inset + translateValue - (arrow ? 2 : 0), posA.y);
            let v6 = lineOrientation == "h" ? createVector(posB.x + totalWidth + translateValue - (arrow ? 2 : 0), posB.y) : createVector(posB.x + totalWidth + inset + translateValue - (arrow ? 2 : 0), posB.y);
            let v7 = p5.Vector.lerp(v5, v6, j == 0 ? incrementB / inset : j * incrementB);
            let v8 = p5.Vector.lerp(v5, v6, j == totalStitchesAcross - 1 ? (j + 1) * incrementB - incrementB / inset : (j + 1) * incrementB);
           
            thisRowA.push(v7);
            if (j==totalStitchesAcross-1) thisRowA.push(v8);

        }

        
        if (colors[col].orderValue % 2 == 0) thisRowA.reverse();
       
        let infillPoly = new Poly(thisRowA,0,0,1,0,0);
        infillPoly.setColorValue(col);
        polys.push(infillPoly);
        thisFillStitchCount++;
        totalFillStitchCount++;
    }

}
function drawUnderlayment(a, b, c, d, fillLineOrientation, color, arrow) {


    let stitchSpacingInMM = underlaymentSpacingInMM;
    let stitchSpacing = stitchSpacingInMM * MM;
    let stitchLength = underlaymentStitchLengthInMM * MM;
    let lineDistX = Math.abs(a[0] - b[0]);
    let lineDistY = Math.abs(a[1] - d[1]);
    let lineLength = fillLineOrientation == "v" ? dist(a[0], a[1], d[0], d[1]) : lineDistX;
    let totalLinesToBeStitched = Math.floor((fillLineOrientation == "v" ? lineDistX : lineDistY) / stitchSpacing);
    let spaceBetweenLinesToBeStitched = (fillLineOrientation == "v" ? lineDistX : lineDistY) / totalLinesToBeStitched;
    let incrementA = spaceBetweenLinesToBeStitched / (fillLineOrientation == "v" ? lineDistX : lineDistY);
    let totalStitchesAcross = Math.floor(lineLength / stitchLength);
    let spaceBetweenStitches = lineLength / totalStitchesAcross;
    let incrementB = spaceBetweenStitches / lineLength;
    let allRows = [];
    for (let i = 1; i <= totalLinesToBeStitched - 1; i++) {
        let thisRow = [];
        let thisRowA = [];

        colors[color].orderValue++;
        let v1 = createVector(a[0], a[1]);
        let v1b = createVector(d[0], a[1]);
        let v2 = fillLineOrientation == "v" ? createVector(b[0], b[1]) : createVector(d[0], d[1]);
        let v2b = createVector(c[0], a[1]);
        let m1 = p5.Vector.lerp(v1, createVector(d[0], d[1]), 0.5);
        let v3 = fillLineOrientation == "v" ? createVector(d[0], d[1]) : createVector(b[0], b[1]);
        let v4 = createVector(c[0], c[1]);
        let m2 = p5.Vector.lerp(v2, createVector(c[0], c[1]), 0.5);

        let posA = p5.Vector.lerp(v1, v2, i * incrementA);
        let posB = p5.Vector.lerp(v3, v4, i * incrementA);
        let posC = p5.Vector.lerp(v1b, v2b, i * incrementA);
        let posD = p5.Vector.lerp(m1, m2, i * incrementA);

        for (let j = 0; j < totalStitchesAcross; j++) {
            let v5 = (j < totalStitchesAcross / 2 && arrow) ? createVector(posC.x + totalWidth + translateValue - 2, posC.y) : arrow ? createVector(posA.x + totalWidth + translateValue - 2, posA.y) : createVector(posA.x + totalWidth + translateValue, posA.y);
            let v6 = (j < totalStitchesAcross / 2 && arrow) ? createVector(posD.x + totalWidth + translateValue - 2, posD.y) : arrow ? createVector(posB.x + totalWidth + translateValue - 2, posB.y) : createVector(posB.x + totalWidth + translateValue, posB.y);
            let v7 = p5.Vector.lerp(v5, v6, j * incrementB * (j < totalStitchesAcross / 2 && arrow ? 2 : 1));
            let v8 = p5.Vector.lerp(v5, v6, (j + 1) * incrementB * (j < totalStitchesAcross / 2 && arrow ? 2 : 1));
            
            let p1a = (colors[color].orderValue % 2 == 0)?[v8,v7]:[v7,v8];

           
            thisRowA.push(v7);
            if (j==totalStitchesAcross-1) thisRowA.push(v8);

        }

        

        
        if (colors[color].orderValue % 2 == 0) thisRowA.reverse();
        for (let z = 0;z<thisRowA.length;z++){
            allRows.push(thisRowA[z]);
        }
      
        

    }
    
    let underlaymentPoly = new Poly(allRows,0,0,1,0,0);
   
    underlaymentPoly.setColorValue(color);
    polys.push(underlaymentPoly);
    
}

function drawArrowBorder(slash) {
    beginShape();
    if (arrow) {
        vertex(vertices[slash][3][0] + totalWidth + translateValue, vertices[slash][0][1]);
        vertex(vertices[slash][2][0] + totalWidth + translateValue, vertices[slash][0][1]);
        let v1 = createVector(vertices[slash][1][0] + totalWidth + translateValue, vertices[slash][1][1]);
        let v2 = createVector(vertices[slash][2][0] + totalWidth + translateValue, vertices[slash][2][1]);
        let midpoint1 = p5.Vector.lerp(v1, v2, 0.5);
        vertex(midpoint1.x, midpoint1.y);
        vertex(vertices[slash][2][0] + totalWidth + translateValue, vertices[slash][2][1]);
        vertex(vertices[slash][3][0] + totalWidth + translateValue, vertices[slash][3][1]);
        let v3 = createVector(vertices[slash][0][0] + totalWidth + translateValue, vertices[slash][0][1]);
        let v4 = createVector(vertices[slash][3][0] + totalWidth + translateValue, vertices[slash][3][1]);
        let midpoint2 = p5.Vector.lerp(v3, v4, 0.5);
        vertex(midpoint2.x, midpoint2.y);
    } else {
        for (let i = 0; i < vertices[slash].length; i++) {
            vertex(vertices[slash][i][0] + totalWidth + translateValue, vertices[slash][i][1]);
        }
    }
    endShape(CLOSE);
}


function drawFillLines(a, b, c, d, spacing, lineOrientation, slash, arrow) {

    if (angle > 0 && lineOrientation == "h") spacing = spacing * (0.6 + angle);
    let stitchSpacingInMM = spacing;
    let stitchSpacing = stitchSpacingInMM * MM;
    let lineDistX = Math.abs(a[0] - b[0]);
    let lineDistY = Math.abs(a[1] - d[1]);
    let totalLinesToBeStitched = Math.floor((lineOrientation == "h" ? lineDistX : lineDistY) / stitchSpacing);
    let spaceBetweenLinesToBeStitched = (lineOrientation == "h" ? lineDistX : lineDistY) / totalLinesToBeStitched;
    let incrementA = spaceBetweenLinesToBeStitched / (lineOrientation == "h" ? lineDistX : lineDistY);


    for (let i = 1; i <= totalLinesToBeStitched - 1; i++) {
        let finishLineChance = R.random_num(0,1);
        let col;
        col = partyMode ? (slashInsideColors[totalCount] + Math.floor(frCount / 2)) % 12 : slashInsideColors[totalCount];

        if (finishLine==true && finishLineChance<0.05 && frCount%3==0 ){
           col= col==12?13:12;
        }

        let v1 = createVector(a[0], a[1]);
        let v1b = createVector(d[0], a[1]);
        let v2 = lineOrientation == "h" ? createVector(b[0], b[1]) : createVector(d[0], d[1]);
        let midPointA = p5.Vector.lerp(v1, v2, 0.5);
        let v3 = lineOrientation == "h" ? createVector(d[0], d[1]) : createVector(b[0], b[1]);
        let v3b = createVector(c[0], b[1]);
        let v4 = createVector(c[0], c[1]);
        let midPointB = p5.Vector.lerp(v3, v4, 0.5);
        let posA = (i < totalLinesToBeStitched / 2 && arrow) ? p5.Vector.lerp(v1b, midPointA, i * incrementA * 2) : p5.Vector.lerp(v1, v2, i * incrementA);
        let posB = (i < totalLinesToBeStitched / 2 && arrow) ? p5.Vector.lerp(v3b, midPointB, i * incrementA * 2) : p5.Vector.lerp(v3, v4, i * incrementA);

        stroke(colors[col].rgb);
        strokeWeight(1);
        let v5 = createVector(posA.x + totalWidth + translateValue, posA.y);
        let v6 = createVector(posB.x + totalWidth + translateValue, posB.y);
        line(v5.x, v5.y, v6.x, v6.y);
        let lineSegments = [];
        let numNodes = lineOrientation == "v" ? 100 : 200;
        for (let i = 0; i <= numNodes; i++) {
            lineSegments.push(p5.Vector.lerp(v5, v6, i / numNodes));
        }
        if (noiseMode) {
            let newColor = shadeColor(colors[col].rgb, -40);
            newColor.push(noiseAlpha<80?Math.floor(noiseAlpha):80);
            stroke(newColor);
            strokeWeight(0.33);
            beginShape();

            for (let j = 0; j <= numNodes; j++) {
                vertex(lineSegments[j].x - (lineOrientation == "h" ? 0.55 : 0) + R.random_num(0, 1.1), lineSegments[j].y - (lineOrientation == "h" ? 0 : 0.55) + R.random_num(0, 1.1));
            }
            endShape();
        }

        totalCount++;
        noiseAlpha = noiseAlpha + frCount/2000;
    }

}

function keyPressed() {
    if (keyCode === 83) {
        saveMyPNG();
    } else if (keyCode === 69) {
        saveMySVG(embroiderySizeW, embroiderySizeH);
    } else if (keyCode === 13) {
        if (partyMode == false) {
            partyMode = true;
        } else {
            partyMode = false;
        }
    } else if (keyCode === 78) {
        if (noiseMode == false) {
            noiseMode = true;
        } else {
            noiseMode = false;
        }
    } else if (keyCode === 32) {
        if (backgroundColor == 255) {
            backgroundColor = 0;
        } else {
            backgroundColor = 255;
        }
    } else if (keyCode === 79) {
        if (outlineMode == false) {
            outlineMode=true;
        } else {
            outlineMode = false;
        }
    } else if (keyCode === 70) {
        if (finishLine == false) {
            finishLine=true;
        } else {
            finishLine = false;
        }
    } else if (keyCode === 76) {
        if (lonely == false){
            forPrint=false;
            lonely=true;
            resizeCanvas(window.innerWidth,window.innerHeight);
            let smallerDim = Math.min(window.innerWidth,window.innerHeight);
            scaler=smallerDim/(embroiderySizeW*2);
        } else {
            lonely=false;
            forPrint=false;
            resizeCanvas(window.innerWidth,window.innerHeight);
            let smallerDim = Math.min(width, height) == width ? width : height;
            scaler = smallerDim / (smallerDim == width ? embroiderySizeW : embroiderySizeH * 2);
        }
    } else if (keyCode==80) {
        if (forPrint==false){
            lonely=false;
            forPrint=true;
            let smallerDim = Math.min(window.innerWidth,window.innerHeight);
            resizeCanvas(smallerDim,smallerDim);
            scaler=smallerDim/(embroiderySizeW*2);
        } else {
            forPrint=false;
            lonely=false;
            resizeCanvas(window.innerWidth,window.innerHeight);
            let smallerDim = Math.min(width, height) == width ? width : height;
            scaler = smallerDim / (smallerDim == width ? embroiderySizeW : embroiderySizeH * 2);
        }
    } else if (keyCode==192) {
        alert("/// is dedicated to my dad who ignited my passion for cars and racing at a very young age.")
    }
}


function drawParallelogram(x1, y1, base, ht, angle) {

    let dx = ht * tan(angle);

    let x2 = x1 + base;
    let y2 = y1;

    let x3 = x1 + dx
    let y3 = y1 - ht;

    let x4 = x1 + base + dx;
    let y4 = y1 - ht;


    return [
        [x3, y3],
        [x4, y4],
        [x2, y2],
        [x1, y1],
        [x3, y3]
    ]; // Looping back to the start
}

function generateEmbroiderySVG(embroiderySizeW, embroiderySizeH) {

    return createSVGCanvas(embroiderySizeW, embroiderySizeH, false);

}

function shadeColor(color, percent) {

    let r = color[0] * (100 + percent) / 100;
    let g = color[1] * (100 + percent) / 100;
    let b = color[2] * (100 + percent) / 100;

    r = (r < 255) ? r : 255;
    g = (g < 255) ? g : 255;
    b = (b < 255) ? b : 255;

    return [Math.round(r), Math.round(g), Math.round(b)];
}