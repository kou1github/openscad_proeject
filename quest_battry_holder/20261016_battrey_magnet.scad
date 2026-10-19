////////////////////
// Quest3 バッテリーホルダー（マグネット埋め込み版）
// 元: quest_battry_holder/20251227_battrey_02.scad
// 変更点:
//   - リングマグネット（外径57.5 / 内径42 / 厚4mm）の溝を底板(+Y壁)に追加
//   - 底板(+Y壁)を外側へ増肉して板厚を確保（wall + plate_extra）
//   - 3面構成: 底板(+Y壁) + 側面(-X壁) + 上蓋(99x21)。前面(-Y)と+X側を開放
////////////////////

////////////////////
// パラメータ（元モデル）
////////////////////
box_w = 99;   // 幅（X）
box_d = 17;   // 奥行き（Y）※内側空洞の奥行き
box_h = 69;   // 高さ（Z）
wall  = 2.0;  // 箱の肉厚

// 元: 切り欠き
slot_w = 1;
slot_d = 5;
slot_off = -2;

// 元: バッテリーインジケータの切り欠き
indicator_w = 20;
indicator_d = 20;

// 元: ベルトループ
loop_extrude = 13;
loop_h       = 39;
loop_thick   = 2.5;
loop_gap_h   = 35;
loop_r       = 0.5;
loop_pos_z   = 10;

////////////////////
// 追加パラメータ（マグネット / 増肉）
////////////////////
// リングマグネット実寸
mag_od = 57.5;  // 外径
mag_id = 42.0;  // 内径
mag_t  = 4.0;   // 厚み

// 溝の逃げ・深さ
mag_clr    = 0.25; // 外周の逃げ（片側）。溝径 = mag_od + 2*mag_clr
mag_clr_id = 0.25; // 中心支柱の逃げ（片側）。支柱径 = mag_id - 2*mag_clr_id
mag_depth  = mag_t;       // 溝の深さ＝磁石厚。磁石面を内面と面一にする（隙間0で鉄板に密着）

// 底板(+Y壁)の増肉量。板厚 = wall + plate_extra
// 5.5mm -> 溝底の残り肉厚 = (wall+plate_extra) - mag_depth = 1.5mm（面一・厚4mm磁石）
plate_extra = 3.5; // 既定: 板厚 5.5mm

// 磁石中心（底板の内面、X-Z平面）
mag_cx = box_w/2;  // 中央
mag_cz = box_h/2;  // 中央

// 底板(+Y壁)の内面Y / 外面Y
y_inner = box_d + wall;                 // = 19
y_outer = box_d + wall + wall + plate_extra; // = 24.5（板厚 5.5mm 時）

// ベルトループ位置（増肉分だけ外側へ）
loop_offsetY = -1.5 + 2*wall + plate_extra;

////////////////////
// メイン形状
////////////////////
module main_box() {
  difference() {
    difference() {
      // 外殻（+Y壁を外側へ増肉）
      cube([box_w, box_d + 2*wall + plate_extra, box_h], center=false);

      // 空洞
      //   X: wall .. box_w        -> -X壁のみ残す（+X側 開放）
      //   Y: 0 .. y_inner         -> -Y壁を除去（前面 開放）
      //   Z: 0 .. box_h-wall      -> 下開放 / 上蓋(-wall..0)を残す
      translate([wall, 0, 0])
        cube([box_w - wall, y_inner, box_h - wall], center=false);
    }

    // 磁石溝（底板の内面にリング状の座ぐり）
    magnet_pocket();

    // インジケータの切り欠き（元。前面開放により実質無効だが形状維持のため残置）
    translate([box_w - indicator_w, -wall, 0]) {
      cube([indicator_w, 3*wall, indicator_d], center=false);
    }
  }
}

// リングマグネット用の環状ポケット
//   - 内面(y_inner)から +Y 方向へ mag_depth だけ彫る
//   - 中心は支柱として残す（支柱径 = mag_id - 2*mag_clr_id）
module magnet_pocket() {
  translate([mag_cx, y_inner - 0.01, mag_cz])
    rotate([-90, 0, 0])
      difference() {
        cylinder(h = mag_depth + 0.01, d = mag_od + 2*mag_clr, center=false, $fn=120);
        cylinder(h = mag_depth + 1.0,   d = mag_id - 2*mag_clr_id, center=false, $fn=120);
      }
}

main_box();
belt_loops();

////////////////////
// ベルトループ（元形状・配置のみ増肉分シフト）
////////////////////
module belt_loop_profile() {
  outer_w = loop_thick*2 + 3;
  bottom_r = outer_w / 2;
  inner_w = outer_w - loop_thick * 2;
  inner_bottom_r = inner_w / 2;
  inner_bottom_y = loop_thick + inner_bottom_r;
  inner_top_y = loop_thick + loop_gap_h;
  $fn = 60;

  difference() {
    union() {
      translate([bottom_r, bottom_r])
        circle(r=bottom_r);
      translate([0, bottom_r])
        offset(r=loop_r) offset(delta=-loop_r)
          square([outer_w, loop_h - bottom_r]);
    }
    union() {
      translate([outer_w/2, inner_bottom_y])
        circle(r=inner_bottom_r);
      translate([loop_thick, inner_bottom_y])
        square([inner_w, inner_top_y - inner_bottom_y]);
    }
    translate([
      outer_w/2 - slot_w/2 + slot_off,
      loop_h - slot_d
    ])
      square([slot_w, slot_d+1], center=false);
  }
}

module belt_loop() {
  rotate([90,0,90])
    linear_extrude(height = loop_extrude, center=false)
      belt_loop_profile();
}

module belt_loops() {
  space = (box_w - 2*loop_extrude) / 3;
  translate([space,
             box_d + loop_offsetY,
             loop_pos_z])
    belt_loop();
  translate([2*space + loop_extrude,
             box_d + loop_offsetY,
             loop_pos_z])
    belt_loop();
}
