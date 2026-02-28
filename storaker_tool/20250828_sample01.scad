// === parameters ===
W  = 70;       // 50mm
H  = 50;       // 50mm
L  = 35;      // 100mm
hole_d = 75;   // 50mm

$fn = 128;       // 円の滑らかさ

difference() {
  // 5cm x 5cm x 10cm の直方体（中心合わせ）
  cube([W, H, L]);

  // 側面（50×100 の面）に対して直径5cmの円柱で貫通穴を開ける
  // 直方体の法線方向（Y軸）に沿うように、Z軸向き円柱をX軸回りに90°回転
  // 厚みH=50mmより少し長い高さを指定して確実に貫通
  rotate([90,0, 0])  // Z軸 → Y軸に向ける
    translate([35,50,-(W+8)])
    cylinder(d = hole_d, h = W + 10);
}

