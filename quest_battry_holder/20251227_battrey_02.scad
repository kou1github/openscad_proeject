////////////////////
// パラメータ
////////////////////
box_w = 99;   // 幅（X）
box_d = 17;   // 奥行き（Y）
box_h = 69;   // 高さ（Z）
wall  = 2.0;  // 箱の肉厚

// 追加パラメータ
slot_w   = 1;   // 切り欠きの幅（Y方向）
slot_d   = 5;   // 切り欠きの深さ（外周から内側へZ方向）
slot_off = -2;   // 中央から少しずらしたい場合のオフセット (Y方向)

// バッテリーインジケータの切り欠き
indicator_w = 20;   // インジケータの幅（Y方向）
indicator_d = 20;   // インジケータの深さ（外周から内側へZ方向）

// ベルトループ
loop_extrude = 13;   // 押し出し厚さ（ベルト幅方向 X）
loop_h       = 39;   // ループ全高（Y方向に倒して使う）
loop_thick   = 2.5;    // ループ板厚
loop_gap_h   = 35;   // ベルトが通る隙間（X方向の高さ）
loop_r       = 0.5;    // 角丸半径
loop_offsetY = -1 + 2*wall;  // 背面からのオフセット
loop_pos_z   = 10;   // 箱底からの取り付け高さ（ループ下端）

////////////////////
// メイン形状
////////////////////
module main_box() {
    difference() {
        difference() {
            cube([box_w, box_d + 2*wall, box_h], center=false);
            translate([wall, wall, 0])
                cube([box_w - wall,
                    box_d ,
                    box_h - wall], center=false);
        }
        translate([box_w-indicator_w, -wall, 0]) {
            cube([indicator_w, 3*wall, indicator_d], center=false);  // インジケータの切り欠き    
        }
    }
}

main_box();
belt_loops();

////////////////////
// ベルトループ断面（元は Y-Z 平面）
////////////////////
// Y=0 が箱背面、Z=0 がループ下端
module belt_loop_profile() {

    outer_w = loop_thick*2 + 3;   // ループ全体の「奥行き」(箱からの出っ張り量)

    // 下部の円弧半径（外側の幅に合わせる）
    bottom_r = outer_w / 2;
    
    // 内側穴の寸法
    inner_w = outer_w - loop_thick * 2;  // 内側の幅
    inner_bottom_r = inner_w / 2;        // 内側下部の円弧半径
    
    // 内側穴の位置
    inner_bottom_y = loop_thick + inner_bottom_r;  // 内側円弧の中心Y
    inner_top_y = loop_thick + loop_gap_h;         // 内側上端Y

    $fn = 60;  // 円弧の滑らかさ

    difference() {
        // 外側形状：下部半円 + 上部角丸四角
        union() {
            // 下部の半円
            translate([bottom_r, bottom_r])
                circle(r=bottom_r);
            
            // 上部の四角形（角丸）
            translate([0, bottom_r])
                offset(r=loop_r)
                offset(delta=-loop_r)
                    square([outer_w, loop_h - bottom_r]);
        }

        // 内側の穴（ベルト通し部）：下部半円 + 上部四角
        union() {
            // 内側下部の半円
            translate([outer_w/2, inner_bottom_y])
                circle(r=inner_bottom_r);
            
            // 内側上部の四角形
            translate([loop_thick, inner_bottom_y])
                square([inner_w, inner_top_y - inner_bottom_y]);
        }

        // 上側の切り欠き
        translate([
            outer_w/2 - slot_w/2 + slot_off,  // X位置（中央基準）
            loop_h - slot_d                    // Y位置（上端から slot_d 分下）
        ])
            square([slot_w, slot_d+1], center=false);
    }
}


// ループ1個：
// 断面(YZ)を X方向に押し出し → Z軸回りに90°回転させて
// 「縦長がY方向・開口が上(＋Z側)」になるようにする
module belt_loop() {
    rotate([90,0,90])                // 断面を寝かせる
        linear_extrude(height = loop_extrude, center=false)
            belt_loop_profile();
}

// 2個並べて背面に沿わせて配置
module belt_loops() {

    // X方向の配置間隔（左右2個）
    space = (box_w - 2*loop_extrude) / 3;

    // 1個目
    translate([space,
               box_d + loop_offsetY,   // 背面から外側へ
               loop_pos_z])            // ループ下端の高さ
        belt_loop();

    // 2個目
    translate([2*space + loop_extrude,
               box_d + loop_offsetY,
               loop_pos_z])
        belt_loop();
}


