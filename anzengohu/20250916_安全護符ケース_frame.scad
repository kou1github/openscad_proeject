// ── Slanted Box Frame + Bottom Plate ─────────────────────────────────
// y=0: 手前（開口側） / y=depth: 背面。上面は前→奥で斜め。
width        = 90;
depth        = 60;
height_front = 110;
height_back  = 120;

rod          = 6;    // 角棒の太さ（正方断面）
plate_thick  = 3;    // 下面プレートの厚み
plate_inside = true; // true: 枠の内側に収める / false: 外形にぴったり

// 2点 p1, p2 をつなぐ角棒（回転なし：小キューブの hull）
module rod_between(p1, p2){
  hull(){
    translate(p1) cube([rod, rod, rod], center=true);
    translate(p2) cube([rod, rod, rod], center=true);
  }
}

// ── コーナー座標 ────────────────────────────────────────────────
FLB = [0,     0,     0];
FRB = [width, 0,     0];
FLT = [0,     0,     height_front];
FRT = [width, 0,     height_front];

BLB = [0,     depth, 0];
BRB = [width, depth, 0];
BLT = [0,     depth, height_back];
BRT = [width, depth, height_back];

// ── フレーム本体（底の四辺は作らず → 下は板にする） ────────────────
module slanted_frame_without_bottom_edges(){
  // 前面（開口側）枠（上・左右）
  rod_between(FLT, FRT);
  rod_between(FLB, FLT);
  rod_between(FRB, FRT);

  // 背面枠（上・左右）
  rod_between(BLT, BRT);
  rod_between(BLB, BLT);
  rod_between(BRB, BRT);

  // 前後連結（上2本は斜め）
  rod_between(FLT, BLT);
  rod_between(FRT, BRT);
}

// ── 下面プレート ────────────────────────────────────────────────
module bottom_plate(){
  if (plate_inside){
    // 枠の内側に収める（左右/前後とも棒の半分だけ内側にオフセット）
    translate([0-rod/2, 0-rod/2, -rod/2])
      cube([width+rod, depth+rod, plate_thick], center=false);
  } else {
    // 外形ぴったり（X:0..width, Y:0..depth）
    cube([width, depth, plate_thick], center=false);
  }
}

// ── 組み立て ────────────────────────────────────────────────────
slanted_frame_without_bottom_edges();
bottom_plate();
