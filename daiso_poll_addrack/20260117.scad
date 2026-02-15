// ===== Parameters =====
case_x     = 170;
case_y     = 85;
case_z     = 15;
atumi      = 2;
arm_height = 18;

$fn = 32;

// ===== Parts =====
module tray(cx, cy, cz, t){
    difference(){
        cube([cx,cy,cz]);
        translate([t,t,t]) cube([cx-2*t, cy-2*t, cz]); // top open
    }
}

// 元の「縦板（側面プレート）」: polygon定義が2回同一だったのでmodule化
module side_plate(sl_x, sl_y, sl_z, cy){
    // 元の points:
    // [0,0],[sl_z,0],[sl_z,cy-sl_y-sl_x],[0,cy-sl_y-sl_x]
    linear_extrude(height=sl_x)
        polygon(points=[
            [0,0],
            [sl_z,0],
            [sl_z, cy - sl_y - sl_x],
            [0,   cy - sl_y - sl_x]
        ]);
}

// 元の「横の三角板」: duplicate point を除去して同一形状に
module brace_triangle(sl_x, sl_z, cx){
    // 元は [0,0],[cx-sl_x,sl_z],[cx-sl_x,sl_z],[0,sl_z]
    // duplicateを除去すると三角形 [0,0],[cx-sl_x,sl_z],[0,sl_z]
    linear_extrude(height=sl_x)
        polygon(points=[
            [0,0],
            [cx - sl_x, sl_z],
            [0, sl_z]
        ]);
}

module joint_01(cx, cy, arm_h,
                sl_x=3, sl_y=15){
    sl_z = arm_h;

    // スリット部（柱3本＋上の連結）
    difference(){
        union(){
            // 柱 0, 2, 4 * sl_x の位置に同形状を3本
            for (i=[0:2:4])
                translate([i*sl_x, 0, 0])
                    cube([sl_x, sl_y, sl_z]);

            // 上の連結（元: translate([0,sl_y,0]) cube([sl_x*(4+1),sl_x,sl_z]);）
            translate([0, sl_y, 0])
                cube([sl_x*5, sl_x, sl_z]);
        }

        // 穴（シリンダ）
        translate([0, sl_y/2, sl_z/2])
            rotate([0,90,0])
                cylinder(h=sl_x*6, r=2.5);
    }

    // 側面プレート2枚（x=sl_x と x=sl_x*3）
    for (xpos=[sl_x, sl_x*3])
        translate([xpos, sl_y, sl_z])
            rotate([0,90,0])
                side_plate(sl_x, sl_y, sl_z, cy);

    // 横の三角板2枚（y=cy/2±4）
    for (ypos=[cy/2-8, cy/2+8])
        translate([sl_x, ypos, 0])
            rotate([90,0,0])
                brace_triangle(sl_x, sl_z, cx);
}

// ===== Assembly =====
translate([0,0,arm_height])
    tray(case_x, case_y, case_z, atumi);

joint_01(case_x, case_y, arm_height);
