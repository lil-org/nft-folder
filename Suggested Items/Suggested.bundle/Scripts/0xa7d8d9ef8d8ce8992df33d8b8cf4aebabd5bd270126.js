let seed = parseInt(tokenData.hash.slice(0, 16), 16);
let p = [];
for (let j = 0; j < 32; j++) {
     p.push(tokenData.hash.slice(2 + (j * 2), 4 + (j * 2)));
}
let z = p.map(x => {
     return parseInt(x, 16) / 255;
});
let maSh,
     sro, mro, hro, sum,
     sf, mf, hf,
     sr0, mr0, hr0,
     wc1, wc2,
     sr1min = 0.2,
     sr1max = 0.3,
     sr2min = 0.41,
     sr2max = 0.55,
     sfL = [0.5, 1, 1.6, 2],
     mr1min = 0.15,
     mr1max = 0.35,
     mr2min = 0.36,
     mr2max = 0.56,
     mfL = [0.4, 0.8, 1.4, 1.75],
     hr1min = 0.1,
     hr1max = 0.35,
     hr2min = 0.36,
     hr2max = 0.54,
     hfL = [0.3, 0.6, 1.2, 1.5],
     wc1L = [1.5, 1.7, 1.9],
     wc2L = [2.0, 2.3, 2.5],
     wcfL = [0.4, 2, 1, 0.2],
     t, t0,
     tL = [6.2, 6.6, 7, 12, 12.5, 14],
     ws = 0.9,
     wm = 1,
     wh = 1.1,
     wbs = 1,
     wbm = 1,
     wbh = 1,
     ra2,
     ra, gs = 200,
     dens,
     cl = false,
     w = false,
     pals = "7dcfcbc4ede79fdfd844b6c51594a8Zf0f9ff8ab4d03f80abd9e4ecbed2dfZ1414144747477a7a7ab8b8b8f7f7f7Z1a31613889ccebf3fa9ac3e5f76d4aZc3464663174af27340420042290029Zed2b2dfe4858ff6a4dff9352ffdb70Zecec7eecb57eec7e7eecd07eed997eZbaf77d8de795e7ff61f4ffdb5ed4afZ0a8a680b504808c48505faa00e1b2fZ14d3ff74d9fba8f2ffe5fffcff8082Z517dec82cfee59b9edc5d0ff875cd6Ze8c0f2da95f9a771f88358fa5f3cfaZ00508500b0b32fdf9367ee87a3fbabZ1b30a710207a010938000529010f5aZdfd9f7017de94f14bd3d094800c8f5Zf67160f77e6eff8861ff9166ff9970Z9060c366d4ffc085ffff579201769dZ78de7d858bdbcbf8252cceab20b6b6Zfcc0d2f1b1cee28dbfcc6bb7853c96Z7400b85e60ce4ea8de56cfe180ffdbZ1bf6fe01b3f9001347015dc600277aZc4f7f156205572557c8a88a5a6c5ceZff66663fcefdffadadfff47b05ffe2Zf9c8caf4e7d7e2c0c7c8b7c5f8d8ceZf44510ffae00901414e70d0d1a0000Zf76464ff2776ffd4e00ef6d0b900f6Z055e0215890257b80e73e702a4f723".split `Z`.map(c => c.match(/.{6}/g).map(s => '#' + s)),
     palp = [4.8, 4.8, 4.8, 4.8, 4.8, 4.8, 4.8, 4.8, 4.8, 4.8, 4.8, 4.8, 4.8, 4.8, 3.1, 3.1, 3.1, 3.1, 3.1, 3.1, 3.1, 3.1, 2, 2, 1.5, 1.5, 1],
     pali, pal, Pts2 = [],
     Ptsb2 = [],
     cL = [],
     cbL = [],
     bg, e, mov, bm, bc, p2, v,
     sec1, sn, mn, hn, s2, m2, h2,
     psec, mrt = 0,
     msh = false,
     msha = 0;

function preload() {
     maSh = getShader(this._renderer);
}

function setup() {
     cnv = createCanvas(windowWidth, windowHeight, WEBGL);
     pixelDensity();
     dens = pixelDensity();
     frameRate();
     colorMode(RGB, 1);
     const gl = canvas.getContext('webgl');
     gl.disable(gl.DEPTH_TEST);

     ra = min(width * dens, height * dens) / 2;
     ra2 = max(width * dens, height * dens) / 2;

     sn = second();
     mn = minute();
     hn = hour();

     psec = sn;
     hprev = hn;
     SetDomains();

     xr = width * dens;
     yr = height * dens;

     if (xr * yr > pow(5760, 2)) {
          xr1 = int(xr * pow(pow(5760, 2) / (xr * yr), 0.5));
          yr1 = int(yr * pow(pow(5760, 2) / (xr * yr), 0.5));
     } else {
          xr1 = xr
          yr1 = yr
     }

     pali = floor(map(z[26], 0, 1, 0, pals.length - 0.01));
     let palt;
     let th = 0;
     pali = 0;
     for (i = 0; i < pals.length; i++) {
          palt = pals[i];
          th += palp[i] / 100;
          if (z[26] * 0.999 > th) {
               pali = i + 1;
          }
     }
     pal = pals[pali];
     p2 = floor(z[28] * 4.99);

     cs = color(pal[(0 + p2) % 5]);
     cm = color(pal[(1 + p2) % 5]);
     ch = color(pal[(2 + p2) % 5]);
     c0 = color(pal[(3 + p2) % 5]);
     cb = color(pal[(4 + p2) % 5]);
     cL = [red(cs), green(cs), blue(cs), red(cm), green(cm), blue(cm), red(ch), green(ch), blue(ch), red(c0), green(c0), blue(c0), red(cb), green(cb), blue(cb)];
     cbL = [1, 0, 0, 0, 1, 0, 0, 0, 1, red(c0), green(c0), blue(c0), red(cb), green(cb), blue(cb)];

     shader(maSh);

     e = z[17] < 0.52 ? 0 : 1;
     e = z[17] > 0.6 ? 2 : e;
     e = z[17] > 0.65 ? 3 : e;
     e = z[17] > 0.75 ? 4 : e;
     e = z[17] > 0.9 ? 5 : e;
     v = z[29] < 0.88 ? 0 : 1
     v = e == 4 ? 0 : v;
     bg = z[18] < 0.65 ? 0 : 1;
     bg = z[18] > 0.85 ? 3 : bg;
     bg = z[18] > 0.95 ? 4 : bg;
     bg = (e == 4 || e == 5) ? 2 : bg;
     mov = z[19] < 0.7 ? 0 : 1;
     bm = z[20] < 0.4 ? 0 : 1;
     bm = z[20] > 0.8 ? 2 : bm;
     bm = (mov == 1 && t0 > 10) ? 0 : bm;
     bm = v == 1 ? 0 : bm;
     bc = z[21] < 0.2 ? 1 : 2;
     bc = z[21] > 0.6 ? 3 : bc;
     bc = bm == 0 ? 0 : bc;
     bc = bm == 2 ? 3 : bc;

     sU("cL", cL);
     sU("xr", xr);
     sU("yr", yr);
     sU("xr1", xr1);
     sU("yr1", yr1);
     sU("dens", dens);
     sU("ra", ra);
     sU("bm", bm);
     sU("bc", bc);
     sU("v", v);
}

function draw() {
     SetPoints();

     let bg2;
     if (w == true) {
          if (bg == 3) {
               bg2 = 4;
          } else {
               bg2 = 3;
          }
          if (e == 4) {
               e2 = 0;
          } else {
               e2 = e;
          }
     } else {
          bg2 = bg;
          e2 = e;
     }

     sU("t", t);
     sU("Pts2", Pts2);
     sU("Ptsb2", Ptsb2);
     sU("cbL", cbL);
     sU("cl", cl);
     sU("bg", bg2);
     sU("e", e2);
     quad(-1, -1, 1, -1, 1, 1, -1, 1);

     if (cl === true) {
          stroke(1);
          let drg = ra / (dens * gs);
          strokeWeight(drg);
          let s2 = createVector(s1.x, s1.y);
          s2.sub(sro);
          s2.normalize();
          line(0, 0, s2.x * 57 * drg, s2.y * 57 * drg);
          strokeWeight(drg * 0.5);
          strokeWeight(2 * drg);
          m1 = m1.sub(mro);
          m1.normalize();
          line(0, 0, m1.x * 45 * drg, m1.y * 45 * drg);
          strokeWeight(drg);
          strokeWeight(3.5 * drg);
          h1 = h1.sub(hro);
          h1.normalize();
          line(0 - h1.x * 0.5 * drg, 0 - h1.y * 0.5 * drg, h1.x * 33 * drg, h1.y * 33 * drg);
          strokeWeight(drg);
     }
}

function getShader(_renderer) {
     const vs =
          `
  precision highp float;
  varying vec2 vPos;
  attribute vec3 aPosition;
  void main() { 
vPos = (gl_Position = vec4(aPosition,1.0)).xy; 
}`;
     const fs =
          `
  precision highp float;
  uniform float xr;
  uniform float yr;
  uniform float xr1;
  uniform float yr1;
  uniform float dens;
  uniform vec3 Pts2[4];
  uniform vec3 Ptsb2[4];
  uniform vec3 Pt;
  uniform vec3 cL[5];
  uniform vec3 cbL[3];
  uniform float t;
  uniform float ra;
  uniform bool cl;
  uniform int e;
  uniform int bg;
  uniform int bm;
  uniform int bc;
  uniform int v;
float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}
  void main() {
    vec3 cs = vec3(cL[0]);
    vec3 cm = vec3(cL[1]);
    vec3 ch = vec3(cL[2]);
    vec3 c0 = vec3(cL[3]);
    vec3 cb = vec3(cL[4]);
    float xcoord = gl_FragCoord.x;
    float ycoord = gl_FragCoord.y;
    vec2 pttest1 = vec2(-30.0,-60.0);
    float rw = 0.0;
    float gw = 0.0;
    float bw = 0.0;
    float sum = 0.0;
    float dsum = 0.0;
    float th = 0.3;
    float xsh; 
    float ysh; 
    float sc; 

    float badj = -1.0 * (1.0/pow(ra/500.0,0.35)+1.895);

    if (xr * yr > pow(5760.0,2.0)){
      sc = pow( xr*yr/pow(5760.0,2.0) ,0.5);
    } else {
      sc = 1.0;
    }

    if (xr * yr > pow(5760.0,2.0)) {
        xsh = (xr - xr1)/2.0;
        ysh = (yr - yr1)/2.0;
    } else {
        xsh = 0.0;
        ysh = 0.0;
    }
    if (bg==4){
      th=0.15;
    }
   for (int i = 0; i < 4; i++) {
      float dx = Pts2[i].x - xcoord * sc + xsh;
      float dy = Pts2[i].y + ycoord * sc - ysh;

      float r = Pts2[i].z;
      float d = pow((dx * dx + dy * dy)+1000.0, -2.0);
      dsum += d;
      sum += (r * r) / (dx * dx + dy * dy);
      rw += d * cL[i].r;
      gw += d * cL[i].g;
      bw += d * cL[i].b;
    }
    if (bm > 0 ) {
      for (int i = 0; i < 3; i++) {

       float dx = Ptsb2[i].x - xcoord * sc + xsh;
       float dy = Ptsb2[i].y + ycoord * sc - ysh;

        float r = Ptsb2[i].z;
        float d = pow((dx * dx + dy * dy)+50.0, badj);
        dsum += d;
        sum += (r * r) / (dx * dx + dy * dy);
        if (bc == 1){
          rw += d * cL[3].r;
          gw += d * cL[3].g;
          bw += d * cL[3].b;
        } else if (bc == 3){
          rw += d * cbL[i].r;
          gw += d * cbL[i].g;
          bw += d * cbL[i].b;
        } else {
          rw += d * cL[i].r;
          gw += d * cL[i].g;
          bw += d * cL[i].b;
        }
      }
    }  
    float t1 = t * 0.00000065 * ra;
    float rav = rw / dsum; 
    float gav = gw / dsum;
    float bav = bw / dsum;
    vec3 color = vec3(rav,gav,bav); 
    vec3 cgb = mix(color,cb, 0.3)+0.2;

    if (v==1){
       if (sum > t1 && sum <= t1 * 3.0) {
        gl_FragColor = vec4(color,1.0);    
        return;
       } else if (sum > t1 * 3.0 && sum <= t1 * 3.1){
          float sum2 = 1.0-map(sum, t1*3.15, t1*3.0,0.0,1.0);
          sum2 = smoothstep(0.2,0.8,sum2);
          gl_FragColor = vec4(mix(color,cb,sum2),1.0);   
          return;
       }else if (sum > t1 * 3.1){
          gl_FragColor = vec4(cb,1.0);    
          return;
       }
    } else{
      if (sum > t1) {
        gl_FragColor = vec4(color,1.0);    
        return;
       } 
    }
    if (bg==1){
      cb = cgb;
    }
    if (bg==3){
      cb=vec3(1.0);
    }
    if (bg==4){
      cb=vec3(0.0);
    }
    if (e==0){
        if (sum <= t1 && sum > t1*0.95) {
          float sum2 = 1.0-map(sum, t1*0.95, t1,0.0,1.0);
          sum2 = smoothstep(0.2,0.8,sum2);
          gl_FragColor = vec4(mix(color,cb,sum2),1.0);   
          return;
      }
    }
   if (e==2){
        if (sum <= t1 && sum > t1*0.6) {
          float sum2 = 1.0-map(sum, t1*0.6, t1,0.0,1.0);
          sum2 = smoothstep(0.2,0.8,sum2);
          gl_FragColor = vec4(mix(color,cb,sum2),1.0);   
          return;
      }
    }
    if (e==1){
      if (sum <= t1 && sum> t1*th){ 
        float sum2 = 1.0-map(sum, t1*th, t1,0.0,1.0);
        sum2 = smoothstep(0.0,0.7,sum2);
        vec3 glow = mix(color, vec3(1.0), 0.2);
        glow = mix(glow, cb, 0.1);
        glow = mix(glow,cb,sum2);
        if (sum > t1*0.95) {
          float sum2 = 1.0-map(sum, t1*0.95, t1,0.0,1.0);
          sum2 = smoothstep(0.2,0.8,sum2);
          gl_FragColor = vec4(mix(color,glow,sum2),1.0);
          return;
        } 
        if (sum <= t1*0.95 && sum > t1*0.4) {
            gl_FragColor = vec4(glow,1.0);
            return;
        }
      }
    } else if (e==3){
        if (sum <= t1 && sum > t1*0.95) {
          float sum2 = 1.0-map(sum, t1*0.95, t1,0.0,1.0);
          sum2 = smoothstep(0.2,0.8,sum2);
          gl_FragColor = vec4(mix(color,mix(color,cb,0.6),sum2),1.0);    
          return;
        } else if (sum <= t1*0.95 && sum > t1*0.75) {
            gl_FragColor = vec4(mix(color,cb,0.6),1.0); 
            return;
        } else if (sum <= t1*0.75 && sum > t1*0.7) {
            float sum2 = 1.0-map(sum, t1*0.7,t1*0.75,0.0,1.0);
            sum2 = smoothstep(0.2,0.8,sum2);
            gl_FragColor = vec4(mix(mix(color,cb,0.6),cb,sum2),1.0); 
        }
    }
    if (bg==1){
      color = cgb;
      gl_FragColor = vec4(color,1.0); 
      return;
    } else if (bg == 2){ 
        vec3 co;
        if (e==4){
          co = vec3(1.0);
        } else {
          co = cb;
        }
        cb = vec3(color)+0.04;
        if (sum <= t1 && sum > t1*0.97) {
          float sum2 = 1.0-map(sum, t1*0.97, t1,0.0,1.0);
          sum2 = smoothstep(0.2,0.8,sum2);
          gl_FragColor = vec4(mix(color,co,sum2),1.0);   
          return;
        } else if (sum <= t1*0.97 && sum > t1*0.94){
          gl_FragColor = vec4(co, 1.0);
           return;
        } else if (sum <= t1*0.94 && sum > t1*0.91) {
          float sum2 = 1.0-map(sum, t1*0.91,t1*0.94,0.0,1.0);
          sum2 = smoothstep(0.2,0.8,sum2);
          gl_FragColor = vec4(mix(co,cb,sum2),1.0); 
          return;
        }
      gl_FragColor = vec4(color,1.0)+0.04;
      return;
    } else if (bg == 3){  
      if (e == 5){
        vec3 co = vec3(cL[4]);
        cb = vec3(1.0);
        if (sum <= t1 && sum > t1*0.97) {
          float sum2 = 1.0-map(sum, t1*0.97, t1,0.0,1.0);
          sum2 = smoothstep(0.2,0.8,sum2);
          gl_FragColor = vec4(mix(color,co,sum2),1.0); 
          return;
        } else if (sum <= t1*0.97 && sum > t1*0.94){
          gl_FragColor = vec4(co, 1.0);
           return;
        } else if (sum <= t1*0.94 && sum > t1*0.91) {
          float sum2 = 1.0-map(sum, t1*0.91,t1*0.94,0.0,1.0);
          sum2 = smoothstep(0.2,0.8,sum2);
          gl_FragColor = vec4(mix(co,cb,sum2),1.0); 
          return;
        }else {
        gl_FragColor = vec4(vec3(1.0),1.0);
        return;
      }
      } else {
        gl_FragColor = vec4(vec3(1.0),1.0);
        return;
      }
    } else if (bg == 4){ 
      gl_FragColor = vec4(0.0,0.0,0.0,1.0);
      return;
    }else {            
      gl_FragColor = vec4(vec3(cL[4]),1.0);
      return;
    }
  }`;
     return new p5.Shader(_renderer, vs, fs);
}

function SetDomains() {
     sr1 = map(z[0], 0, 1, sr1min, sr1max) * ra;
     sr2 = map(z[1], 0, 1, sr2min, sr2max) * ra;
     mr1 = map(z[2], 0, 1, mr1min, mr1max) * ra;
     mr2 = map(z[3], 0, 1, mr2min, mr2max) * ra;
     hr1 = map(z[4], 0, 1, hr1min, hr1max) * ra;
     hr2 = map(z[5], 0, 1, hr2min, hr2max) * ra;

     sf = sfL[floor(z[6] * sfL.length * 0.99)];
     mf = mfL[floor(z[7] * mfL.length * 0.99)];
     hf = hfL[floor(z[8] * hfL.length * 0.99)];
     wcf = wcfL[floor(z[9] * wcfL.length * 0.99)];

     t0 = tL[floor(z[10] * tL.length * 0.99)];

     wc1 = wc1L[floor(z[11] * wc1L.length * 0.99)];
     wc2 = wc2L[floor(z[12] * wc2L.length * 0.99)];

     ws *= ra / gs;
     wm *= ra / gs;
     wh *= ra / gs;

     wbs *= ra / gs;
     wbm *= ra / gs;
     wbh *= ra / gs;

     wc1 *= ra / gs;
     wc2 *= ra / gs;

     t = t0 * gs / ra;
}

function SetPoints() {

     let time = [second(), minute(), hour(), millis() / 1000];
     let hc = time[2];
     let mc = time[1];
     let sc = time[0];
     let sec = time[3];
     let ms = millis();

     if (psec != sc) {
          mrt = ms;
     }

     var mils = constrain(floor(ms - mrt) / 1000, 0, 1);

     if (psec != sc && frameCount != 1 && msh == false) {
          msh = true;
          msha = 1 - ms / 1000;
     }

     mils = mils - msha;
     psec = sc;

     s2 = sc + mils;
     m2 = mc + (sc / 60) % 1
     h2 = (hc + (mc / 60) % 1) % 12;

     s = map(s2, 0, 60, 0, TWO_PI) - HALF_PI;
     m = map(m2, 0, 60, 0, TWO_PI) - HALF_PI;
     h = map(h2, 0, 12, 0, TWO_PI) - HALF_PI;

     sr = map(cos((sec) * sf), -1, 1, sr1, sr2);
     mr = map(cos((sec) * mf), -1, 1, mr1, mr2);
     hr = map(cos((sec) * hf), -1, 1, hr1, hr2);
     wc = map(cos((sec) * wcf), -1, 1, wc1, wc2);

     let b0 = 12 * ra / gs;

     let sbr = map(sr, sr1, sr2, sr - b0 / 1.5, sr - b0 / 1.5);
     let mbr = map(mr, mr1, mr2, mr - b0 / 1.5, mr - b0 / 1.5);
     let hbr = map(hr, hr1, hr2, hr - b0 / 1.5, hr - b0 / 1.5);

     if (bm == 1) {
          sbr = map(sr, sr1, sr2, b0, sr2 - b0);
          mbr = map(mr, mr1, mr2, b0, mr2 - b0);
          hbr = map(hr, hr1, hr2, b0, hr2 - b0);
     };
     if (bc == 3) {
          let sbcr = 1 - map(sr, sr1, sr2, 0, 1);
          let mbcr = 1 - map(mr, mr1, mr2, 0, 1);
          let hbcr = 1 - map(hr, hr1, hr2, 0, 1);

          let sbc = lerpColor(c0, cs, sbcr);
          let mbc = lerpColor(c0, cm, mbcr);
          let hbc = lerpColor(c0, ch, hbcr);
          cbL = [red(sbc), green(sbc), blue(sbc), red(mbc), green(mbc), blue(mbc), red(hbc), green(hbc), blue(hbc)];
     }

     let sb1 = createVector(cos(s) * sbr, sin(s) * sbr);
     let mb1 = createVector(cos(m) * mbr, sin(m) * mbr);
     let hb1 = createVector(cos(h) * hbr, sin(h) * hbr);

     Ptsb2 = [sb1.x + xr1 / 2, sb1.y - yr1 / 2, wbs, mb1.x + xr1 / 2, mb1.y - yr1 / 2, wbm, hb1.x + xr1 / 2, hb1.y - yr1 / 2, wbh, 0.0 + xr1 / 2, 0.0 - yr1 / 2, wc];

     s1 = createVector(cos(s) * sr, sin(s) * sr);
     m1 = createVector(cos(m) * mr, sin(m) * mr);
     h1 = createVector(cos(h) * hr, sin(h) * hr);

     if (mov == 1) {
          sro = createVector(cos(sec * 2.6) * ra / 10, sin(sec * 2.6) * ra / 10);
          s1 = s1.add(sro);
          mro = createVector(cos(sec * 2.6) * ra / 30, sin(sec * 2.6) * ra / 30);
          m1 = m1.add(mro);
          hro = createVector(cos(sec * 2.6) * ra / 50, sin(sec * 2.6) * ra / 50);
          h1 = h1.add(hro);
     }
     Pts2 = [s1.x + xr1 / 2, s1.y - yr1 / 2, ws, m1.x + xr1 / 2, m1.y - yr1 / 2, wm, h1.x + xr1 / 2, h1.y - yr1 / 2, wh, 0.0 + xr1 / 2, 0.0 - yr1 / 2, wc];



}

function mousePressed() {
     if (cl == false) {
          cl = true;
     } else {
          cl = false;
     }
}

function mousePressed() {
     if (cl == false) {
          cl = true;
     } else {
          cl = false;
     }
}

function keyPressed() {
     if (keyCode === 87) {
          if (w == false) {
               w = true;
          } else {
               w = false;
          }
     }
     if (keyCode === 83) {
          save(cnv, floor(h2) + "-" + floor(m2) + "-" + round(s2, 2) + "_" + tokenData.hash + ".png");
     }
}

function sU(a, b) {
     maSh.setUniform(a, b);
}