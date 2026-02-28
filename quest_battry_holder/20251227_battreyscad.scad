////////////////////
// パラメータ
////////////////////
box_w = 99;   // 幅（X）
box_d = 17;   // 奥行き（Y）
box_h = 69;   // 高さ（Z）
wall  = 2.0;  // 箱の肉厚

// ベルトループ
loop_extrude = 13;   // 押し出し厚さ（ベルト幅方向 X）
loop_h       = 39;   // ループ全高（Y方向に倒して使う）
loop_thick   = 3;    // ループ板厚
loop_gap_h   = 35;   // ベルトが通る隙間（X方向の高さ）
loop_r       = 1;    // 角丸半径
loop_offsetY = 2.5;  // 背面からのオフセット
loop_pos_z   = 15;   // 箱底からの取り付け高さ（ループ下端）

////////////////////
// メイン形状
////////////////////
module main_box() {
    difference() {
        cube([box_w, box_d, box_h], center=false);
        translate([wall, wall, 0])
            cube([box_w - wall,
                  box_d - 2*wall,
                  box_h - wall], center=false);
    }
}

main_box();
belt_loops();

////////////////////
// ベルトループ断面（元は Y-Z 平面）
////////////////////
// Y=0 が箱背面、Z=0 がループ下端
module belt_loop_profile() {

    outer_w = loop_thick*2 + 4;   // ループ全体の「奥行き」（箱からの出っ張り量）

    inner_bottom = loop_thick;
    inner_top    = inner_bottom + loop_gap_h;

    difference() {
        // 外側輪郭
        offset(r=loop_r)
            polygon(points=[
                [0, 0],
                [outer_w, 0],
                [outer_w, loop_h],
                [0, loop_h]
            ]);

        // 内側の穴（ベルト通し部）
        offset(r=loop_r)
            polygon(points=[
                [loop_thick,           inner_bottom],
                [outer_w - loop_thick, inner_bottom],
                [outer_w - loop_thick, inner_top],
                [loop_thick,           inner_top]
            ]);
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