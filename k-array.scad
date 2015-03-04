// units: mm
delta = 0.01; // prevent zero length walls.
connector_x = 6.75; //width
connector_z = 3.26; //height
connector_y = 1.5; //length

block_y = 4.5 + connector_y;
block_z_base = 1;
block_z = connector_z + block_z_base;
block_connector_wall_x = 1;
block_x = connector_x + 2 * block_connector_wall_x;
guide_y = 15;
guide_diameter = 1;

wiring_x = 5.6;
wiring_y = 3+4*delta;
wiring_z = connector_z+1;
wiring_x_offset = (block_x - wiring_x) / 2;

module block (){
  cube([block_x, block_y, block_z], center = false);
}

module connector (){
  cube([connector_x, connector_y, connector_z], center = false);
}

module guide_cut(){
  union(){
    rotate([90,0,0]){
      cylinder(h=guide_y, r=guide_diameter/2, center=false, $fn=100);
    }
    translate([-guide_diameter/2,-guide_y,0]){
      cube([guide_diameter, guide_y, 5], center=false);
    }
  }
}

cut_x = 5.5;
cut_y = 4;
module right_cut(){
  translate([-cut_x+block_x/2,cut_y,-delta])
  rotate([0,0,-30]){
    cube([5,10,10], center=true);
  }
}
module left_cut(){
  translate([cut_x+block_x/2,cut_y,-delta])
  rotate([0,0,30]){
    cube([5,10,10], center=true);
  }
}

module top_cut(){
  translate([-delta,-1,connector_z])
  rotate([-15,0,0]){
    cube(20,5,5);
  }
}

module wiring_space(){
  cube([wiring_x, wiring_y, wiring_z]);
}

module main(){
  difference(){
    block();
    translate([block_connector_wall_x, -delta, block_z_base + delta]){
      connector();
    }
    translate([block_x/2, block_y + delta, block_z_base]){
      guide_cut();
    }
    translate([wiring_x_offset, connector_y-2*delta, 
	       block_z_base]){
      wiring_space();
    }
    right_cut();
    left_cut();
    top_cut();
  }
}

main();


