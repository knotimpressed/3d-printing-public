// TODO: add gasket object
// push to github for kyle

inside_height_param = 28;//[16:1:240]
inside_diameter_param = 26;//[7:1:94]
additional_cap_height_param = 0;//[0:50]
knurled_container_param = true;//[0:1]
knurled_cap_param = true;//[0:1]
expand_interior_param = true;//[0:1]
// needs to be 1 not true because its used in math
include_ring_param = 1;//[0:1]
include_gasket_param = 1;//[0:1]
ring_height_param = 4;//[1:50]
ring_text_param = "M D K";
PieceToRender = 0; //[0:All pieces, 1:Container, 2:Cap, 3:Ring, 4:Gasket]


//Overall height with cap and ring will be inside_height + 4

if (PieceToRender == 0 || PieceToRender == 1) {
  container(inside_height_param, inside_diameter_param, expand_interior_param, knurled_container_param, include_ring_param, ring_height_param);
}

if (PieceToRender == 0 || PieceToRender == 2) {
  cap(inside_diameter_param, knurled_cap_param, additional_cap_height_param);
}

if ((PieceToRender == 0 || PieceToRender == 3) && include_ring_param == 1) {
  ring(inside_diameter_param, ring_text_param);
}

if ((PieceToRender == 0 || PieceToRender == 4) && include_gasket_param == 1) {
  ring(inside_diameter_param, ring_text_param);
}

module container(inside_height, inside_diameter, expand_interior, knurled_cap, include_ring, ring_height){
  $fn = 60;
  inside_radius = inside_diameter / 2;
  knn = round((inside_diameter + 8));
  ka = (120 / knn);
  inside_height_magic = inside_height - 8;
  difference(){
    union(){

      //threads
      translate([0, 0, inside_height_magic])
      linear_extrude(height = 10, twist = -180 * 10)
      translate([0.5, 0])
      circle(r = inside_radius + 1.5);

      //body
      cylinder(r = inside_radius + 4, h = inside_height_magic - include_ring * ring_height_param);

      //neck   
      if (include_ring == 1) {
        cylinder(r = inside_radius + 2.5, h = inside_height - 3.99 - include_ring * ring_height_param);
      }


    }
    if (expand_interior == 0) {
      translate([0, 0, 2])
      cylinder(r = inside_radius, h = inside_height + 0.1);
    }
    else {
      //inner cavity
      translate([0, 0, 2])
      cylinder(r = inside_radius + 2.5, h = inside_height - 15.99);

      //neck cavity
      translate([0, 0, inside_height_magic])
      cylinder(r = inside_radius, h = 12);

      //cavity transition
      translate([0, 0, inside_height - 14])
      cylinder(r1 = inside_radius + 2.5, r2 = inside_radius, h = 6.01);
    }

    //top chamfer
    translate([0, 0, inside_height + 2])
    rotate_extrude()
    translate([inside_radius + 4.5, 0])
    circle(r = 4, $fn = 4);

    //bottom chamfer
    rotate_extrude()
    translate([inside_radius + 4, 0])
    circle(r = 1.6, $fn = 4);

    if (knurled_cap == 1) {
      //knurling
      for (j = [0: knn - 1])
        for (k = [-1, 1]) {
          rotate([0, 0, j * 360 / knn])
          linear_extrude(height = inside_height - 7.99 + include_ring * ring_height_param, twist = k * ka * (inside_height - 7.99 + include_ring * ring_height), $fn = 30)
          translate([inside_radius + 4, 0])
          circle(r = 0.8, $fn = 4);
        }
    }
  }
}

module cap(inside_diameter, knurled_cap, additional_cap_height){
  $fn = 60;
  inside_radius = inside_diameter / 2;
  knn = round((inside_diameter + 8) * 1.0);
  ka = 120 / knn;

  translate([inside_diameter + 10, 0, 0])
  difference(){
    cylinder(r = inside_radius + 4, h = 12 + additional_cap_height);

    translate([0, 0, 2 + additional_cap_height])
    linear_extrude(height = 10.1, twist = -180 * 10.1)
    translate([0.5, 0])
    circle(r = inside_radius + 1.8);

    rotate_extrude()
    translate([inside_radius + 4, 0])
    circle(r = 1.6, $fn = 4);

    if (knurled_cap == 1) {

      for (j = [0: knn - 1])
        for (k = [-1, 1])
          rotate([0, 0, j * 360 / knn])
      linear_extrude(height = 12.1 + additional_cap_height, twist = k * ka * (12.1 + additional_cap_height), $fn = 30)
      translate([inside_radius + 4, 0])
      circle(r = 0.8, $fn = 4);

    }
    translate([0, 0, 10 + additional_cap_height])
    cylinder(r1 = inside_radius + 1.5, r2 = inside_radius + 2.5, h = 2.1);

    translate([0, 0, 2])
    cylinder(r = inside_radius, h = additional_cap_height + 0.1);
  }
}

module ring(inside_diameter, ring_text){
  $fn = 160;
  inside_radius = inside_diameter / 2;
  translate([0, inside_diameter + 10, 0])
  difference(){
    cylinder(r = inside_radius + 4, h = 4);
    translate([0, 0, -0.1])
    cylinder(r = inside_radius + 2.6, h = 4.2);


    txt = str(ring_text);
    rot = 180 / (inside_radius + 4);

    for (i = [0: len(txt) - 1]) {
      rotate([0, 0, rot * i])
      translate([0, -inside_radius + -3.2, 0.6])
      rotate([90, 0, 0])
      linear_extrude(height = 1)
      text(txt[i], size = 2.8, halign = "center", valign = "bottom");
    }
  }
}
