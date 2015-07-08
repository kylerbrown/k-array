// Created  by Kyler Brown, 2015

// units: mm
// connector: omnetics A8366-001   NPD-14-WD-18.0-GS

// *** makerbot replicator 2 specs ***
/*
Print Technology
Fused Deposition Modeling

Layer Resolution
100 microns [0.0039 in]

Positioning Precision
XY: 11 microns [0.0004 in]
Z: 2.5 microns [0.0001 in]

Filament Diameter
1.75 mm [0.069 in]

Nozzle Diameter
0.4 mm [0.015 in] 
*/



delta = 0.01; // prevent zero length walls.

connector_x = 5.54;
connector_z = 4.49;
connector_y = 2.56;
connector_wall_dia = 1.1;
connector_cut_x = 1.5;

block_x = 4;
block_y = 1.5;
block_z = 5;

cut_angle  = 10;
guide_diameter = .5;

module connector_holder (){
  difference(){
    cube([connector_x + 2*connector_wall_dia,
	  connector_y + 2*connector_wall_dia,
	  connector_z,
	  ]);
    translate([connector_wall_dia, connector_wall_dia, -delta]){
      cube([connector_x, connector_y, connector_z+2*delta]);
    }
    //strain relief cut
    translate([connector_wall_dia + connector_x /2 - connector_cut_x/2,
	        connector_wall_dia + connector_y -delta, -delta]){
      cube([connector_cut_x, 2*connector_wall_dia + 2*delta + connector_y, connector_z+2*delta]);
    }
  }
}



module block(){
  difference(){
    cube([block_x, block_y, block_z]);
    translate([6,0,3]){
      rotate([0,cut_angle,0]){
	cube([6,15,10], center=true);
      }
    }
    translate([-2,0,3]){
      rotate([0,-cut_angle,0]){
	cube([6,15,10], center=true);
      }
    }
  }
}

leg_length = block_x;
leg_dia = 1.5;
module block_with_legs(){
  union(){
    block();
    translate([0,0,0]){
      difference(){
	cube([leg_length, leg_dia, leg_dia]);
	translate([5.0, -delta,-1]){
	  rotate([0,-45,0]){
	    cube([leg_length, leg_dia+2*delta, 10]);
	  }
	}
	translate([-6.7, -delta,-1]){
	  rotate([0,45,0]){
	    cube([leg_length, leg_dia+2*delta, 10]);
	  }
	}
      }
    }
  }

}

module guide_cut(){
  union(){
    rotate([0,0,0]){
      cylinder(h=block_z+2*delta, r=guide_diameter/2, center=false, $fn=40);

      translate([-guide_diameter/2,-block_z, 0]){
	cube([guide_diameter, block_z, block_z+delta], center=false);
      }
    }
  }
}

module block_with_guide(){
  difference(){
    block_with_legs();
    translate([block_x/2, 0, -delta]){
      guide_cut();
    }

  }

}

// guides for wires

contact_h = 1.2;
contact_dia = 1.2; //connector wire diameter with insulation = 0.4mm
contact_wall_depth = 1.7;
module contact_guide(n0, length){
  // a securing feature to connect electrodes to connector channels
  contact_spacing = (length+2*connector_wall_dia) / (n0);
  difference(){
    cube([contact_spacing*(n0), contact_wall_depth, contact_h]);
    for (i = [1:n0]){
      translate([contact_spacing/4+contact_spacing*(i-1), contact_wall_depth-contact_dia, -delta])
	cube([contact_dia, contact_dia, contact_h+2*delta]);//*10+3*delta);
    }
  }
}

module all_contact_guides(){
  foo = (connector_x+2*connector_wall_dia)/4/4;
  translate([0, -contact_wall_depth+delta, connector_z-contact_h]){
    contact_guide(4, connector_x);
  }
  
  translate([-1*contact_wall_depth, -contact_wall_depth+delta, connector_z]){
    rotate([180,0,90]){
      contact_guide(3, connector_y+1);
    }
  }
  translate([connector_x+2*connector_wall_dia+contact_wall_depth,
	     -contact_wall_depth+delta, connector_z-contact_h]){
    rotate([0,0,90]){
      contact_guide(3, connector_y+1);
    }
  }
}

//connector_holder();

module full_array(){
  union(){
    connector_holder();
    translate([(connector_wall_dia + connector_x/2 - block_x/2),
	       -block_y/2,
	       -block_z/2]){
      block_with_guide();
    }
  }
}

union(){
  full_array();
  all_contact_guides();
}
