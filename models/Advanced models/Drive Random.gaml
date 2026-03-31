/**
* Name: Drive Random (แบบเพิ่มคำอธิบายภาษาไทย)
* Description: แบบจำลองยานพาหนะขับเคลื่อนแบบสุ่มบนโครงข่ายถนน (Road Graph)
* Author: Duc Pham (บรรยายภาษาไทยโดย Gemini)
* Tags: gis, shapefile, graph, agent_movement, skill, transport
*/

model DriveRandom

// นำเข้าโมเดล Traffic พื้นฐาน (ต้องมีไฟล์ Traffic.gaml ในโฟลเดอร์เดียวกัน)
import "Traffic.gaml"

global {
	/** --- ส่วนตั้งค่าพารามิเตอร์เริ่มต้น --- **/
	float seed <- 42.0; // กำหนดค่า Seed เพื่อให้การสุ่มผลลัพธ์ออกมาเหมือนเดิมทุกครั้งที่รัน
	float traffic_light_interval init: 60#s; // กำหนดระยะเวลาเปลี่ยนไฟจราจร (60 วินาที)
	float step <- 0.2#s; // กำหนดความละเอียดของเวลาในแต่ละรอบการคำนวณ (Time Step)

	string map_name; // ชื่อโฟลเดอร์ที่เก็บข้อมูลแผนที่
	// โหลดไฟล์ Shapefile ของถนนและจุดตัด (Nodes) ตามชื่อแมพที่เลือก
	file shp_roads <- file("../../includes/" + map_name + "/roads.shp");
	file shp_nodes <- file("../../includes/" + map_name + "/nodes.shp");

	// กำหนดขอบเขตของพื้นที่จำลอง (Boundary) โดยอิงจากไฟล์ถนนและบวกเพิ่ม 50 หน่วย
	geometry shape <- envelope(shp_roads) + 50;
	
	int num_cars; // ตัวแปรเก็บจำนวนรถยนต์
	int num_motorbikes; // ตัวแปรเก็บจำนวนรถมอเตอร์ไซค์

	graph road_network; // ตัวแปรสำหรับเก็บโครงข่ายถนนในรูปแบบ Graph (Nodes & Edges)
	list<intersection> non_deadend_nodes; // รายการจุดตัดที่ไม่ใช่ทางตัน

	/** --- ส่วนเริ่มต้นระบบ (Setup) --- **/
	init {
		// 1. สร้างถนนจาก Shapefile
		create road from: shp_roads {
			num_lanes <- rnd(4, 6); // สุ่มจำนวนเลนระหว่าง 4 ถึง 6 เลน
			
			// สร้างถนนขากลับ (Opposite direction) สำหรับถนนทุกเส้น
			create road {
				num_lanes <- myself.num_lanes;
				shape <- polyline(reverse(myself.shape.points)); // กลับทิศทางของเส้น
				maxspeed <- myself.maxspeed;
				linked_road <- myself; // เชื่อมโยงถนนสองฝั่งเข้าด้วยกัน
				myself.linked_road <- self;
			}
		}
		
		// 2. สร้างจุดตัด (Intersections) จาก Shapefile
		create intersection from: shp_nodes
				with: [is_traffic_signal::(read("type") = "traffic_signals")] {
			time_to_change <- traffic_light_interval; // ตั้งเวลาสัญญาณไฟ
		}
		
		// 3. สร้าง Graph สำหรับการขับขี่
		// กำหนดน้ำหนัก (Weight) ของถนนแต่ละเส้นด้วยระยะทาง (Perimeter)
		map edge_weights <- road as_map (each::each.shape.perimeter);
		// แปลงถนนและจุดตัดให้กลายเป็น Graph เพื่อใช้ในการคำนวณเส้นทาง
		road_network <- as_driving_graph(road, intersection) with_weights edge_weights;
		
		// เก็บรายชื่อจุดตัดที่มีทางออก (ไม่ใช่ทางตัน) เพื่อใช้ในการสุ่มตำแหน่งเริ่มต้น
		non_deadend_nodes <- intersection where !empty(each.roads_out);
		
		// สั่งให้จุดตัดเริ่มทำงาน (ตั้งค่าสัญญาณไฟ)
		ask intersection {
			do initialize;
		}
		
		// 4. สร้างยานพาหนะตามจำนวนที่กำหนดใน Experiment
		create motorbike_random number: num_motorbikes;
		create car_random number: num_cars;
	}
}

/** --- ส่วนการนิยามพฤติกรรมของยานพาหนะ --- **/

// Species หลักของยานพาหนะ (สืบทอดคุณสมบัติจาก base_vehicle ใน Traffic.gaml)
species vehicle_random parent: base_vehicle {
	init {
		road_graph <- road_network; // กำหนด Graph ที่ใช้ขับขี่
		location <- one_of(non_deadend_nodes).location; // สุ่มจุดเกิดจากจุดตัด
		right_side_driving <- true; // กำหนดให้ขับเลนขวา (สามารถเปลี่ยนเป็น false สำหรับเลนซ้ายแบบไทย)
	}

	// Reflex (พฤติกรรมอัตโนมัติ): ย้ายที่ใหม่เมื่อถึงทางตันหรือไม่มีเป้าหมายต่อ
	reflex relocate when: next_road = nil and distance_to_current_target = 0.0 {
		do unregister; // ออกจากถนนเดิม
		location <- one_of(non_deadend_nodes).location; // วาร์ปไปจุดเริ่มต้นใหม่
	}
	
	// Reflex: ขับเคลื่อนไปเรื่อยๆ แบบสุ่ม
	reflex commute {
		do drive_random graph: road_graph;
	}
}

// นิยามรถมอเตอร์ไซค์
species motorbike_random parent: vehicle_random {
	init {
		vehicle_length <- 1.9 #m; // ความยาวรถ
		num_lanes_occupied <- 1;  // กินพื้นที่ 1 เลน
		max_speed <- (50 + rnd(20)) #km / #h; // สุ่มความเร็วสูงสุด 50-70 กม./ชม.

		// ตั้งค่าพฤติกรรมการขับขี่
		proba_block_node <- 0.0; // โอกาสที่จะจอดขวางทางแยก
		proba_respect_priorities <- 1.0; // เคารพลำดับการไปก่อน-หลัง
		proba_respect_stops <- [1.0]; // เคารพป้ายหยุด
		proba_use_linked_road <- 0.5; // โอกาสที่จะแซงข้ามเลนไปถนนฝั่งตรงข้าม (ถ้าว่าง)

		lane_change_limit <- 2; // ขีดจำกัดการเปลี่ยนเลน		
		linked_lane_limit <- 1; // ขีดจำกัดการล้ำเลนสวน
	}
}

// นิยามรถยนต์
species car_random parent: vehicle_random {
	init {
		vehicle_length <- 3.8 #m; // ความยาวรถ (ยาวกว่ามอเตอร์ไซค์)
		num_lanes_occupied <- 2;  // กินพื้นที่ 2 เลน (ขนาดใหญ่กว่า)
		max_speed <- (60 + rnd(10)) #km / #h; // สุ่มความเร็วสูงสุด 60-70 กม./ชม.
				
		proba_block_node <- 0.0;
		proba_respect_priorities <- 1.0;
		proba_respect_stops <- [1.0];
		proba_use_linked_road <- 0.0; // รถยนต์ไม่สามารถวิ่งเลนสวนได้ (ในโมเดลนี้)

		lane_change_limit <- 2;			
		linked_lane_limit <- 0;
	}
}

/** --- ส่วนการแสดงผล (Experiments) --- **/

// Experiment 1: แบบวงเวียน (Ring)
experiment ring type: gui {
	parameter 'Traffic light interval' var:traffic_light_interval;
	
	action _init_{ 
		create simulation with:[
			map_name::"ring", // ใช้ข้อมูลในโฟลเดอร์ ring
			num_cars::50,     // รถยนต์ 50 คัน
			num_motorbikes::100 // มอเตอร์ไซค์ 100 คัน
		];
	}

	output synchronized: true {
		display map type: 2d background: #gray {
			species road aspect: base;
			species car_random aspect: base;
			species motorbike_random aspect: base;
			species intersection aspect: base;
		}
	}
}

// Experiment 2: แบบเมือง (City - Rouen)
experiment city type: gui {
	action _init_{
		create simulation with:[
			map_name::"rouen", // ใช้ข้อมูลในโฟลเดอร์ rouen
			num_cars::100,    // รถยนต์ 100 คัน
			num_motorbikes::200 // มอเตอร์ไซค์ 200 คัน
		];
	}

	output synchronized: true {
		display map type: 2d background: #gray {
			species road aspect: base;
			species car_random aspect: base;
			species motorbike_random aspect: base;
			species intersection aspect: base;
		}
	}
}