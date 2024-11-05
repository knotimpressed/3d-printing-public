// TODO:
// add slider to change $fn
// add tolerance slider for gasket

// notes: lack of syntax errors sucks
// semicolons are WEIRD

PieceToRender = 0; //[0:All pieces, 1:Container, 2:Cap, 3:Ring, 4:Gasket]
inside_height_param = 28;//[16:1:240]
inside_diameter_param = 26;//[7:1:94]
additional_cap_height_param = 0;//[0:50]
knurled_container_param = true;//[0:1]
knurled_cap_param = true;//[0:1]
expand_interior_param = true;//[0:1]
// needs to be 1 not true because its used in math
include_ring_param = 1;//[0:1]
include_gasket_param = 1;//[0:1]
gasket_thickness_param = 2.2;//[0:0.01:2]
// 0-2 range? really 0- (2-gasket thickness)
cap_top_thickness_param = 1.0;//[0:0.1:2] 
peg_diameter_param = 1.0;//[0:4:10] 
ring_height_param = 4;//[1:50]
ring_text_param = "M D K";


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
   gasket(inside_diameter_param, gasket_thickness_param, cut = false, peg_diameter=peg_diameter_param);
}

// yeah its obj 4 but its at the top, deal with it
module gasket(inside_diameter, gasket_thickness, cut, cap_top_thickness = 0, peg_diameter){
    $fn = 60; // 60 facets
    // if block makes a new scope so we have to do this :(
    origin_x = cut ? inside_diameter + 10 : -10 - inside_diameter;
    origin_z = cap_top_thickness;
    wall_thickness = -1.25; //  TODO calculate
    inside_radius = inside_diameter / 2;
    
    //translate([origin_x, 0, origin_z])
    //cylinder(r = inside_radius -wall_thickness, h = gasket_thickness);
    translate([origin_x, 0, origin_z])
    difference(){
        cylinder(r = inside_radius -wall_thickness, h = gasket_thickness);
        cylinder(r = 7/2, h = gasket_thickness+2);
    }
}

module container(inside_height, inside_diameter, expand_interior, knurled_cap, include_ring, ring_height){
  $fn = 60; // this is the number of facets, short and dumb and fixed name
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

  difference(){
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
      
    //cut out gaskets spot (no tolerances for now)  
    gasket(inside_diameter, gasket_thickness_param, cut = true, cap_top_thickness = cap_top_thickness_param, peg_diameter=peg_diameter_param);
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
