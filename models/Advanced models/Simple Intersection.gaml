/**
* Name: Mix Drive City (แบบเพิ่มคำอธิบายภาษาไทย)
* Description: แบบจำลองการขับขี่รถยนต์บนโครงข่ายถนนและระบบไฟจราจร
* Author: Duc Pham and Patrick Taillandier (บรรยายภาษาไทยโดย Gemini)
*/

model simple_intersection

global {
	/** --- ส่วนตั้งค่าสภาพแวดล้อม --- **/
	float size_environment <- 1#km; // ขนาดพื้นที่จำลอง 1x1 กิโลเมตร
	geometry shape <- envelope(size_environment);
	float step <- 0.5 #s; // ความละเอียดของเวลา (1 รอบ = 0.5 วินาที)
	
	//float lane_width <- 2.0; // ความกว้างของเลน (สำหรับแสดงผล)
	float lane_width <- 2.0; // ความกว้างของเลน (สำหรับแสดงผล)
	
	int num_cars <- 1;     // จำนวนรถ
	float proba_block_node_car <- 1.0; // โอกาสที่รถจะหยุดขวางทางแยก (1.0 = 100%)
	
	graph road_network; // โครงข่ายถนนแบบ Graph

//	init {
//		/** --- สร้างจุดตัด (Intersections) ตามพิกัด --- **/
//		create intersection with: (location: {10, size_environment/2}); // จุดซ้ายสุด
//		create intersection with: (location: {size_environment/2, size_environment/2}); // จุดกลาง
//		create intersection with: (location: {size_environment / 2 + 30, size_environment/2}, is_traffic_signal: true); // ไฟแดง
//		create intersection with: (location: {size_environment - 10, size_environment/2}); // จุดขวาสุด
//		create intersection with: (location: {size_environment/2, 10}); // จุดบน
//		create intersection with: (location: {size_environment/2, size_environment - 10}); // จุดล่าง
//		
//		/** --- สร้างถนนเชื่อมจุดตัด (Roads) --- **/
//		create road with:(num_lanes:1, maxspeed: 50#km/#h, shape:line([intersection[0],intersection[1]]));
//		create road with:(num_lanes:1, maxspeed: 50#km/#h, shape:line([intersection[1],intersection[2]]));
//		create road with:(num_lanes:1, maxspeed: 50#km/#h, shape:line([intersection[2],intersection[3]]));
//		create road with:(num_lanes:1, maxspeed: 50#km/#h, shape:line([intersection[4],intersection[1]]));
//		create road with:(num_lanes:1, maxspeed: 50#km/#h, shape:line([intersection[1],intersection[5]]));
//		
//		// สร้าง Graph จากถนนและจุดตัดที่สร้างไว้
//		road_network <- as_driving_graph(road, intersection);
//		
//		// ตั้งค่าเริ่มต้นให้สัญญาณไฟจราจร
//		ask intersection where each.is_traffic_signal {
//			do initialize;
//		}
//	}




//init {
//    // 1. สร้างจุดตัด (Intersections) วางเป็นแนว Grid
//    // แถวบน
//    create intersection with: (location: {200, 200}); // id: 0
//    create intersection with: (location: {500, 200}, is_traffic_signal: true); // id: 1
//    create intersection with: (location: {800, 200}); // id: 2
//    
//    // แถวกลาง
//    create intersection with: (location: {200, 500}, is_traffic_signal: true); // id: 3
//    create intersection with: (location: {500, 500}); // id: 4 (ใจกลางเมือง)
//    create intersection with: (location: {800, 500}, is_traffic_signal: true); // id: 5
//    
//    // แถวล่าง
//    create intersection with: (location: {200, 800}); // id: 6
//    create intersection with: (location: {500, 800}, is_traffic_signal: true); // id: 7
//    create intersection with: (location: {800, 800}); // id: 8
//
//    // 2. สร้างถนนเชื่อมต่อกัน (แนวนอน)
//    create road with:(num_lanes:2, shape:line([intersection[0], intersection[1]]));
//    create road with:(num_lanes:2, shape:line([intersection[1], intersection[2]]));
//    create road with:(num_lanes:2, shape:line([intersection[3], intersection[4]]));
//    create road with:(num_lanes:2, shape:line([intersection[4], intersection[5]]));
//    create road with:(num_lanes:2, shape:line([intersection[6], intersection[7]]));
//    create road with:(num_lanes:2, shape:line([intersection[7], intersection[8]]));
//
//    // 3. สร้างถนนเชื่อมต่อกัน (แนวตั้ง)
//    create road with:(num_lanes:2, shape:line([intersection[0], intersection[3]]));
//    create road with:(num_lanes:2, shape:line([intersection[3], intersection[6]]));
//    create road with:(num_lanes:2, shape:line([intersection[1], intersection[4]]));
//    create road with:(num_lanes:2, shape:line([intersection[4], intersection[7]]));
//    create road with:(num_lanes:2, shape:line([intersection[2], intersection[5]]));
//    create road with:(num_lanes:2, shape:line([intersection[5], intersection[8]]));
//
//    // สร้าง Graph และตั้งค่าไฟจราจร
//    road_network <- as_driving_graph(road, intersection);
//    ask intersection where each.is_traffic_signal {
//        do initialize;
//    }
//}








init {
    // 1. สร้างจุดศูนย์กลางของสี่แยก (Center) และเปิดระบบไฟจราจร
    create intersection with: (location: {500, 500}, is_traffic_signal: true) ; // id: 0
    
    // 2. สร้างจุดปลายถนนทั้ง 4 ทิศ
    create intersection with: (location: {500, 100});  // ทิศเหนือ (North) - id: 1
    create intersection with: (location: {500, 900});  // ทิศใต้ (South) - id: 2
    create intersection with: (location: {100, 500});  // ทิศตะวันตก (West) - id: 3
    create intersection with: (location: {900, 500});  // ทิศตะวันออก (East) - id: 4

    // 3. สร้างถนนแบบ 2 เลน (ไป-กลับ) เชื่อมเข้าสู่จุดศูนย์กลาง
    // ถนนแนวตั้ง (North-South)
    create road with:(num_lanes:2, shape:line([intersection[1], intersection[0]])); // เหนือมากลาง
    create road with:(num_lanes:2, shape:line([intersection[0], intersection[2]])); // กลางไปใต้
    create road with:(num_lanes:2, shape:line([intersection[2], intersection[0]])); // ใต้มากลาง
    create road with:(num_lanes:2, shape:line([intersection[0], intersection[1]])); // กลางไปเหนือ

    // ถนนแนวนอน (West-East)
    create road with:(num_lanes:2, shape:line([intersection[3], intersection[0]])); // ตกมากลาง
    create road with:(num_lanes:2, shape:line([intersection[0], intersection[4]])); // กลางไปตะวันออก
    create road with:(num_lanes:2, shape:line([intersection[4], intersection[0]])); // ตะวันออกมากลาง
    create road with:(num_lanes:2, shape:line([intersection[0], intersection[3]])); // กลางไปตะวันตก

    // สร้าง Graph และตั้งค่าเริ่มต้นไฟจราจร
    road_network <- as_driving_graph(road, intersection);
    ask intersection where each.is_traffic_signal {
        do initialize;
    }
}







	
	// Reflex: เพิ่มรถเข้าสู่ระบบตลอดเวลาที่จุดเริ่มต้น
//	reflex add_car {
//		create car with: (location: intersection[0].location, target: intersection[3]); // วิ่งซ้ายไปขวา
//		create car with: (location: intersection[4].location, target: intersection[5]); // วิ่งบนลงล่าง
//	}


//	reflex add_car {
//	    // สุ่มสร้างรถ 2 คันทุกๆ Step โดยสุ่มจุดเริ่มต้นและจุดหมายไม่ให้ซ้ำกัน
//	    intersection start_node <- one_of(intersection);
//	    intersection target_node <- one_of(intersection where (each != start_node));
//	    
//	    create car with: (location: start_node.location, target: target_node);
//	}



reflex add_car {
    // กำหนดรายการจุดทางเข้า-ออก (ไม่รวมจุดศูนย์กลางที่เป็นสี่แยก)
    list<intersection> entrance_nodes <- [intersection[1], intersection[2], intersection[3], intersection[4]];
    
    // สุ่มเลือกจุดเกิดและจุดหมายจากทางทิศต่างๆ
    intersection start_node <- one_of(entrance_nodes);
    intersection target_node <- one_of(entrance_nodes where (each != start_node));
    
    create car with: (location: start_node.location, target: target_node);
}


	
}

/** --- Species ถนน --- **/
species road skills: [road_skill]{
	string type;
	string oneway;
	aspect base_ligne {
		draw shape color: #white end_arrow:100; // วาดเส้นถนนสีขาวพร้อมลูกศรบอกทิศทาง
	}
} 

/** --- Species จุดตัดและสัญญาณไฟจราจร --- **/
species intersection skills: [intersection_skill] {
    bool is_traffic_signal <- false;
    float time_to_change <- 20#s; // เวลาไฟเขียวแต่ละฝั่ง
    float counter <- 0.0;
    bool is_green_vertical <- true; // เริ่มต้นให้แนวตั้งเป็นไฟเขียว

    // รายการถนนในแต่ละแนว
    list<road> vertical_roads;
    list<road> horizontal_roads;

    action initialize {
        if is_traffic_signal {
            // แยกถนนตามมุม (แนวตั้งคือมุมประมาณ 90/270, แนวนอนคือ 0/180)
            loop rd over: roads_in {
                float ang <- road(rd).shape.perimeter; // หรือใช้มุมจากจุดเริ่มต้น-สิ้นสุด
                point p1 <- first(road(rd).shape.points);
                point p2 <- last(road(rd).shape.points);
                float angle <- p1 direction_to p2;
                
                if (angle > 45 and angle < 135) or (angle > 225 and angle < 315) {
                    vertical_roads << road(rd);
                } else {
                    horizontal_roads << road(rd);
                }
            }
            do update_signal;
        }
    }

    action update_signal {
        if is_green_vertical {
            // แนวตั้งเขียว -> แนวนอนต้องหยุด
            stop << [horizontal_roads]; 
            stop[0] <- horizontal_roads;
        } else {
            // แนวนอนเขียว -> แนวตั้งต้องหยุด
            stop << [vertical_roads];
            stop[0] <- vertical_roads;
        }
    }

    reflex dynamic_node when: is_traffic_signal {
        counter <- counter + step;
        if (counter >= time_to_change) {
            counter <- 0.0;
            is_green_vertical <- !is_green_vertical; // สลับฝั่ง
            do update_signal;
        }
    }

    aspect base {
        if is_traffic_signal {
            // วาดไฟจราจร 2 ดวงเพื่อแสดงสถานะแต่ละฝั่ง
            draw circle(15) color: (is_green_vertical ? #green : #red) at: {location.x - 20, location.y};
            draw circle(15) color: (is_green_vertical ? #red : #green) at: {location.x, location.y - 20};
        }
        draw square(30) color: #darkgray;
    }
}

/** --- Species รถยนต์ --- **/
species car skills: [driving] {
	rgb color <- rnd_color(255);
	intersection target; // จุดหมายปลายทาง
	
	init {
		vehicle_length <- 3.8 #m;
		num_lanes_occupied <-1;
		max_speed <-150 #km / #h;
				
		proba_block_node <- proba_block_node_car;
		proba_respect_priorities <- 1.0;
		proba_respect_stops <- [1.0];
		proba_use_linked_road <- 0.0;
		lane_change_limit <- 2;
		linked_lane_limit <- 0;
	}

	// Reflex: คำนวณเส้นทางสั้นที่สุดไปยังเป้าหมาย
	reflex choose_path when: final_target = nil {
		do compute_path graph: road_network target: target; 
	}

	// Reflex: ขับรถ และหายไปเมื่อถึงจุดหมาย
	reflex move when: final_target != nil {
		do drive;
		if (final_target = nil) {
			do unregister; // ออกจากระบบถนน
			do die;        // ลบตัวตนรถออก
		}
	}
	
	// ฟังก์ชันคำนวณตำแหน่งสำหรับแสดงผล (ขยับรถให้ตรงเลน)
	point compute_position {
		if (current_road != nil) {
			float dist <- (road(current_road).num_lanes - lowest_lane - 0.5) * lane_width;
			if violating_oneway { dist <- -dist; }
		 	point shift_pt <- {cos(heading + 90) * dist, sin(heading + 90) * dist};	
			return location + shift_pt;
		} else { return {0, 0}; }
	}
	
	aspect default {
		if (current_road != nil) {
			point pos <- compute_position();
			// วาดตัวรถเป็นรูปสี่เหลี่ยม
			draw rectangle(vehicle_length*4, lane_width * num_lanes_occupied*4) 
				at: pos color: color rotate: heading border: #black;
			// วาดสามเหลี่ยมหน้ารถเพื่อบอกทิศทาง
			draw triangle(lane_width * num_lanes_occupied) 
				at: pos color: #white rotate: heading + 90 ;
		}
	}
}

/** --- การแสดงผล --- **/
experiment simple_intersection type: gui {
	output synchronized: true {
		display city type: 3d background: #black axes: false{
			species road aspect: base_ligne;
			species intersection aspect: base;
			species car ;
		}
	}
}