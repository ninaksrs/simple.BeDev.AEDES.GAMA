model DriveRandomManualRoad

import "Traffic.gaml"

global {
    float seed <- 42.0;
    float traffic_light_interval init: 20#s;
    float step <- 0.2#s;
    geometry shape <- envelope(1000#m);
    
    int num_cars <- 30;
    int num_motorbikes <- 50;

    graph road_network;
    list<intersection> non_deadend_nodes;

    init {
        create intersection with: (location: {500, 500}, is_traffic_signal: true); 
        create intersection with: (location: {500, 100}); 
        create intersection with: (location: {500, 900}); 
        create intersection with: (location: {100, 500}); 
        create intersection with: (location: {900, 500}); 

        do create_road_pair(intersection[1], intersection[0]); 
        do create_road_pair(intersection[0], intersection[2]); 
        do create_road_pair(intersection[3], intersection[0]); 
        do create_road_pair(intersection[0], intersection[4]); 

        road_network <- as_driving_graph(road, intersection);
        non_deadend_nodes <- [intersection[1], intersection[2], intersection[3], intersection[4]];
        
        // สั่งให้จุดตัดเริ่มทำงานโดยใช้ Action ที่มีอยู่แล้วใน Traffic.gaml
        ask intersection {
            do initialize;
        }
        
        create motorbike_random number: num_motorbikes;
        create car_random number: num_cars;
    }

    action create_road_pair(intersection start_node, intersection end_node) {
        create road {
            shape <- line([start_node.location, end_node.location]);
          //  num_lanes <- 3;
            maxspeed <- 50#km/#h;
            num_lanes <- 3; // เพิ่มเป็น 3 เลนต่อฝั่งเพื่อให้รถมีพื้นที่กระจายตัว
            create road {
                num_lanes <- 3;
                shape <- polyline(reverse(myself.shape.points));
                maxspeed <- 50#km/#h;
                linked_road <- myself;
                myself.linked_road <- self;
            }
        }
    }
}

/** * เนื่องจากใน Traffic.gaml มี species intersection อยู่แล้ว 
* เราจะใช้คำสั่ง 'refine' หรือ 'customize' ผ่าน species เดิม 
**/
species intersection_custom parent: intersection {
    // หากต้องการสร้าง logic ใหม่จริงๆ ให้ใช้ชื่ออื่นแล้วไปสร้างแทนใน init
    // แต่ในกรณีนี้ แนะนำให้ใช้ intersection เดิมจาก Traffic.gaml 
    // ซึ่งปกติจะมีความสามารถพื้นฐานมาให้อยู่แล้ว
}

/** --- Species ยานพาหนะ --- **/
species vehicle_random parent: base_vehicle {
    init {
        road_graph <- road_network;
        location <- one_of(non_deadend_nodes).location;
        right_side_driving <- true;
        proba_respect_priorities <- 1.0;
        proba_respect_stops <- [1.0];
    }

    reflex relocate when: next_road = nil and distance_to_current_target = 0.0 {
        do unregister;
        location <- one_of(non_deadend_nodes).location;
    }
    
    reflex commute {
        do drive_random graph: road_graph;
    }
}

species motorbike_random parent: vehicle_random {
    init {
        vehicle_length <- 1.9 #m;
        num_lanes_occupied <- 1;
        max_speed <- (40 + rnd(10)) #km / #h;
    }
}

//species car_random parent: vehicle_random {
//    init {
//        vehicle_length <- 4.0 #m;
//        num_lanes_occupied <- 2;
//        max_speed <- (50 + rnd(10)) #km / #h;
//        proba_block_node <- 0.0; // รถจะไม่หยุดขวางกลางแยกเด็ดขาด
//        min_safety_distance <- 2.0 #m; // ระยะห่างขั้นต่ำระหว่างคัน
//		max_acceleration <- 2.0 #m/#s; // ลดอัตราเร่งให้สมูทขึ้น
//    }
//}





// ... ส่วน global เดิม ...

species car_random parent: vehicle_random {
    init {
        vehicle_length <- 4.5 #m; 
        num_lanes_occupied <- 1; // ลองใช้ 1 เลนเพื่อให้รถเข้าแถวตรงกันมากขึ้น
        max_speed <- (40 + rnd(10)) #km / #h;
        
        // --- ส่วนที่ทำให้เป็นระเบียบ ---
        proba_block_node <- 0.0; // ห้ามขวางทางแยก
        min_safety_distance <- 2.5 #m; // รักษาระยะห่าง
        proba_respect_priorities <- 1.0; 
        proba_respect_stops <- [1.0];
    }

    
}







experiment "Four-way Random Drive" type: gui {
    output synchronized: true {
        display map type: 2d background: #black {
            species road aspect: base;
            species car_random aspect: base;
            species motorbike_random aspect: base;
            species intersection aspect: base;
        }
    }
}