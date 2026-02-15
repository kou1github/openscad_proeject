// ============================================================
// φ25×19ピンで既存受けに差し込み、150mm下に「Wall Guard風」受けを付ける
// - 下側：角丸プレート + 低いリング(リム) + 中央の浅い皿（例示画像に寄せる）
// ============================================================

$fn = 96;

// ---------- 表示 ----------
show_adapter = true;
show_test_tension_rod = false;

// ---------- 差し込みピン（既存受けへ） ----------
pin_d_nominal = 25;
pin_len       = 19;
pin_clearance = 0.4;
pin_chamfer   = 1.0;
pin_delimiter = 9; // 壁付きのピン受けの最大厚み

// ---------- 吊り下げ ----------
drop_mm = 150;

// アーム
arm_th = 8.0;  // X厚
arm_w  = 16.0; // Y幅
arm_len = drop_mm;
neck_h = 10.0;

// ---------- 下側：Wall Guard風 ----------
plate_w = 55;
plate_h = 55;
plate_t = 3.0;
plate_r = 6.0;     // 角丸R（例示っぽく）

// 受け座（リング＋皿）
rim_od   = 34;      // 受け座リング外径（キャップより少し大きい）
rim_id   = 26;      // 受け座リング内径（キャップ外径に近い）
rim_h    = 5.0;     // リング高さ（低め）

dish_d     = 18;    // 中央の浅い皿 直径
dish_depth = 2.0;   // 皿深さ

// プレートとリングの“つながり”の滑らかさ
blend_h = 2.0;      // 0〜3程度：大きいほどなだらか

// ---------- テスト用：突っ張り棒端（簡易） ----------
test_endcap_d = 28; // 端キャップ径イメージ
test_endcap_t = 6;
test_rod_d     = 25;
test_rod_len   = 120;

// ---- A: ガセット（補強リブ） ----
gusset_len   = 16;   // Z方向（下方向）への伸び
gusset_h     = 14;   // X方向（外側）への伸び
gusset_y_th  = 3.0;  // ガセット1枚の厚み（Y方向）
gusset_gap   = 0.6;  // アーム側面から少し離す/食い込ませ回避
gusset_inset = 0.2;  // 壁面側へ少しめり込ませて隙間対策

// ============================================================
// 角丸四角（2D）
// ============================================================
module rounded_rect_2d(w, h, r){
  r2 = min(r, min(w,h)/2);
  offset(r=r2) square([w-2*r2, h-2*r2], center=true);
}

// 角丸プレート（3D）
module rounded_plate(w,h,t,r){
  linear_extrude(height=t, center=false)
    rounded_rect_2d(w,h,r);
}

// ============================================================
// 差し込みピン（+X方向へ）
// ============================================================
module insert_pin(){
  pin_d = pin_d_nominal - pin_clearance;

  color([0.95,0.8,0.15,1.0])
    translate([plate_t,0,0]){
        union(){
            rotate([0,90,0])
            translate([0,0,0]){
                cylinder(h=pin_len, r=pin_d/2, center=false);
            }
            translate([0,0,0])
            rotate([0,-90,0])
                cylinder(h=pin_chamfer,
                        r1=pin_d/2,
                        r2=max(pin_d/2 - pin_chamfer, 0.1),
                        center=false);
        }
    }

    translate([0,0,-pin_len + pin_delimiter/2]){
        rotate([90,0,0]){
            difference(){
                translate([0,-3,0]){
                    linear_extrude(height = 45+2, center = true){
                        polygon(points = [
                            [0, 0],   // 直角の頂点
                            [pin_len + 2+2, 0], 
                            [pin_len + 2+2, pin_d_nominal+(pin_delimiter+2)] 
                        ]);
                    }
                }
                linear_extrude(height = 45, center = true){
                    polygon(points = [
                        [0, 0],   // 直角の頂点
                        [pin_len + 2, 0],  
                        [pin_len + 2, pin_d_nominal+(pin_delimiter+2)] 
                    ]);
                }
            }
        }
    }

}

// ============================================================
// Wall Guard風 受け（例示に寄せた構造）
// 座標：壁面を x=0 とし、プレートの壁当たり面が x=0 に来るようにする
// ＝プレート厚は +x 側へ
// ============================================================
module wall_guard_like(){
  color([0.95,0.8,0.15,1.0])
  difference(){
    union(){
      // 1) 角丸プレート
      translate([0,0,0])
        rotate([0,90,0])
            rounded_plate(plate_w, plate_h, plate_t, plate_r);

      // 2) リング本体（中空）
      difference(){
        translate([plate_t + rim_h/2, 0, 0])
          rotate([0,90,0])
            cylinder(h=rim_h, r=rim_od/2, center=true);

        translate([plate_t + rim_h/2, 0, 0])
          rotate([0,90,0])
            cylinder(h=rim_h+0.4, r=rim_id/2, center=true);

        translate([plate_t + rim_h/2, 0, rim_od/2/2])
          rotate([0,90,0])
            cube([rim_od/2, rim_od+0.4,rim_h+0.4], center=true);
      }
    }
  }
}

// ============================================================
// A) アーム根元のガセット（片側）
// 断面は X-Z 平面の三角形、Y方向に厚み gusset_y_th で押し出し
// ============================================================
module arm_gusset_one(side=+1){
  // side=+1: +Y側, side=-1: -Y側
  y0 = side*(arm_w/2 + gusset_gap - 14);  // アーム外側へ少しオフセット
  rotate_x = (side == +1) ? 0 : 180;
  // Z=0 をアーム上端に合わせて使う想定（呼び出し側で translate）
  translate([gusset_y_th+2, y0 - gusset_y_th/2, -gusset_y_th])
    rotate([rotate_x,90,0]){
        linear_extrude(height=gusset_y_th, center=false)
        polygon(points=[
            [plate_t - gusset_inset, 0],                 // 根元（壁側寄り）
            [plate_t + arm_th + gusset_h, 0],            // 外へ
            [plate_t - gusset_inset, -gusset_len]        // 下へ（アーム方向）
        ]);
        }
}

// 両側に配置
module arm_gusset_both(){
  union(){
    arm_gusset_one(+1);
    arm_gusset_one(-1);
  }
}

// ============================================================
// アダプタ全体
// ============================================================
module adapter(){
  union(){
    // 上：差し込みピン
    insert_pin();

    translate([0, 0, -(pin_delimiter-2)]){
        union()
        // アーム
            color([0.95,0.8,0.15,1.0])
            translate([arm_th/2, 0, -(neck_h + arm_len/2 )])
                cube([arm_th, arm_w, arm_len], center=true);

            // 下：Wall Guard風
            translate([0,0,-(neck_h + arm_len + rim_od/2)])
            wall_guard_like();
        }
    }

    // ★A: ガセット（アーム上端付近 = Zが -neck_h）
    color([0.95,0.8,0.15,1.0])
    translate([0, 0, -neck_h-1])
    arm_gusset_both();

}

// ============================================================
// テスト用：突っ張り棒端
// ============================================================
module test_tension_rod(){
  z = -(neck_h + arm_len);
  color([0.9,0.1,0.1,0.55])
  union(){
    // 端キャップ（プレートに当たる）
    translate([plate_t + test_endcap_t/2, 0, z])
      rotate([0,90,0])
        cylinder(h=test_endcap_t, r=test_endcap_d/2, center=true);

    // 棒本体
    translate([plate_t + test_endcap_t + test_rod_len/2, 0, z])
      rotate([0,90,0])
        cylinder(h=test_rod_len, r=test_rod_d/2, center=true);
  }
}

// ============================================================
// 出力
// ============================================================
if (show_adapter) adapter();
if (show_test_tension_rod) test_tension_rod();