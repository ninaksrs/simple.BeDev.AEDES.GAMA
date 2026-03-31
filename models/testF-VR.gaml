model GamaToUnityUDP_Multi_model_VR

import "testF.gaml"

species unity_linker parent: abstract_unity_linker {
	string player_species <- string(unity_player);
	int max_num_players  <- 4;
	int min_num_players  <- 1;
	
	
	
	unity_property up_map_agent;
	//unity_property up_default;
	unity_property up_car;
	unity_property up_dog;
	unity_property up_home;
	list<point> init_locations <- define_init_locations();

	list<point> define_init_locations {
		return [{10.0,10.0,0.0},{50.0,50.0,0.0},{50.0,50.0,0.0},{50.0,50.0,0.0}];
	}


	init {
		do define_properties;
		//player_unity_properties <- [nil,nil,nil,nil];
		//do add_background_geometries(map_agent,up_map_agent);
	}
	action define_properties {
		unity_aspect map_agent_aspect <- prefab_aspect("Prefabs/Visual Prefabs/City/Vehicles/Map",1.0,-1.0,1.0,0.0,precision);
		up_map_agent <- geometry_properties("map_agent","",map_agent_aspect,#no_interaction,false);
		unity_properties << up_map_agent;


//		unity_aspect default_aspect <- prefab_aspect("Prefabs/Visual Prefabs/City/Vehicles/Moto",1.0,0.0,1.0,0.0,precision);
//		up_default <- geometry_properties("default","",default_aspect,#no_interaction,false);
//		unity_properties << up_default;


		unity_aspect car_aspect <- prefab_aspect("Prefabs/Visual Prefabs/City/Vehicles/Car",1.0,0.0,1.0,0.0,precision);
		up_car <- geometry_properties("car","",car_aspect,#no_interaction,false);
		unity_properties << up_car;


		unity_aspect dog_aspect <- prefab_aspect("Prefabs/Visual Prefabs/City/Vehicles/Car",1.0,0.0,1.0,0.0,precision);
		up_dog <- geometry_properties("dog","",dog_aspect,#no_interaction,false);
		unity_properties << up_dog;


		unity_aspect home_aspect <- prefab_aspect("Prefabs/Visual Prefabs/City/Vehicles/Home",100.0,50.0,100.0,0.0,precision);
		up_home <- geometry_properties("home","",home_aspect,#no_interaction,false);
		unity_properties << up_home;


	}
	reflex send_geometries {
		do add_geometries_to_send(car,up_car);
		do add_geometries_to_send(dog,up_dog);
		do add_geometries_to_send(home,up_home);
		do add_geometries_to_send(map_agent,up_map_agent);
	}
	
	
	
	
	
	// ไม่ส่งข้อมูล world ไป Unity ทุก step (ช่วยลดโหลด)
	//bool do_send_world <- false;
	bool do_send_world <- true;
	
	// 🔁 ทำงานทุก 100 cycle และต้องมี player อยู่
	reflex send_message when: every(100 #cycle) and not empty(unity_player){
		
		// แสดงข้อความใน console
		//write "Send message: "  + cycle;
		
		// 📤 ส่ง message ไปยัง player ทุกคนใน Unity
		// รูปแบบเป็น map: "ชื่อข้อมูล"::ค่า
		//do send_message players: unity_player as list mes: ["cycle":: cycle];
	}
	
		// 📥 รับ message จาก Unity
//	action receive_message (string id, string mes, int hp, float x, int score) {
//		write "Player " + id + " send the message: " + mes + " score: " + score;
//	
//	// --- เพิ่มส่วนนี้เพื่อให้คะแนนอัปเดตใน GAMA ---
//    ask unity_player where (each.name = id) {
//        self.score <- score;
//    }
//	
//	}





//action receive_message (string id, string mes, int hp, float x, int score) {
//    write "Player " + id + " send the message: " + mes + " score: " + score;
//    
//    // ลองใช้ 'first' เพื่อหา agent ตัวที่ชื่อตรงกัน
//    unity_player target_p <- first(unity_player where (each.name = id));
//    
//    if (target_p != nil) {
//        ask target_p {
//            self.score <- score;
//        }
//    } else {
//        // ถ้าหาไม่เจอ ให้ลอง print ชื่อที่มีทั้งหมดในระบบมาเช็ค
//        write "Error: Cannot find player with id " + id + ". Available: " + (unity_player collect each.name);
//    }
//}




action receive_message (string id, string mes, int hp, float x, int score) {
    string clean_id <- lower_case(id);
    
    // 1. ฝากค่า score ที่รับมาจาก Unity ไว้ในตัวแปรชั่วคราวชื่อ temp_score
    int temp_score <- score; 
    
    unity_player target_p <- first(unity_player where (lower_case(each.name) = clean_id));
    
    if (target_p != nil) {
        ask target_p {
            // 2. นำค่าจากตัวแปรชั่วคราวมาใส่ให้ตัวผู้เล่น
            self.score <- temp_score; 
            
            write "SUCCESS! Updated " + self.name + " to: " + self.score;
        }
    } else {
        write "Looking for: " + clean_id + " but not found.";
    }
}
	
	
	
}

species unity_player parent: abstract_unity_player{
	float player_size <- 100.0;
	rgb color <- #red;
	float cone_distance <- 10.0 * player_size;
	float cone_amplitude <- 90.0;
	float player_rotation <- 90.0;
	bool to_display <- true;
	float z_offset <- 2.0;
	
	int score <- 0; // <--- เพิ่มบรรทัดนี้
	string ip <- ""; // <--- เพิ่มบรรทัดนี้เพื่อเก็บค่า IP ของผู้เล่นแต่ละคน
	
	aspect default {
		if to_display {
			if selected {
				 draw circle(player_size) at: location + {0, 0, z_offset} color: rgb(#blue, 0.5);
			}
			draw circle(player_size/2.0) at: location + {0, 0, z_offset} color: color ;
			draw player_perception_cone() color: rgb(color, 0.5);
		}
	}
	
	
	
	
	reflex debug_score {
        // ให้มันตะโกนบอกคะแนนตัวเองใน Console ทุกๆ step
         write name + " has score: " + score;
    }
}




//species unity_player parent: abstract_unity_player {
//    float player_size <- 1.0;
//    rgb color <- #red;
//    float cone_distance <- 10.0 * player_size;
//    float cone_amplitude <- 90.0;
//    float player_rotation <- 90.0;
//    bool to_display <- true;
//    float z_offset <- 2.0;
//    
//    // เพิ่มตัวแปรสำหรับเก็บค่าตำแหน่งแบบอ่านง่าย (Optional)
//    point my_position -> {location.x, location.y, location.z};
//
//    aspect default {
//        if to_display {
//            if selected {
//                draw circle(player_size) at: location + {0, 0, z_offset} color: rgb(#blue, 0.5);
//                
//                // --- ส่วนที่เพิ่ม: แสดงพิกัด (x, y) เป็นข้อความเมื่อถูกเลือก ---
//                draw "Pos: " + string(location.x, 1) + ", " + string(location.y, 1) 
//                     at: location + {player_size, player_size, z_offset + 1} 
//                     color: #black font: font("SansSerif", 12, #bold);
//            }
//            
//            draw circle(player_size/2.0) at: location + {0, 0, z_offset} color: color;
//            draw player_perception_cone() color: rgb(color, 0.5);
//        }
//    }
//}



experiment vr_xp parent:"Main" autorun: false type: unity {
	float minimum_cycle_duration <- 0.1;
	
	string unity_linker_species <- string(unity_linker);
	
	list<string> displays_to_hide <- ["test","test"];
	
	float t_ref;

	action create_player(string id) {
		ask unity_linker {
			do create_player(id);
		}
	}

	action remove_player(string id_input) {
		if (not empty(unity_player)) {
			ask first(unity_player where (each.name = id_input)) {
				do die;
			}
		}
	}


	
	 
	

	


	output {
		 display test_VR parent:test{
			 species unity_player;
			 event #mouse_down{
				 float t <- gama.machine_time;
				 if (t - t_ref) > 500 {
					 ask unity_linker {
						 move_player_event <- true;
					 }
					 t_ref <- t;
				 }
			 }
		 }
		 
		 
//	display point_player parent:test {
//    species unity_player;
//    
//    graphics "display_score" {
//        ask unity_player {
//            // แสดงเฉพาะค่าตัวเลข score
//            draw string(self.score) 
//                at: location + {0, 0, 50.0} // วาดไว้ตรงกลางเหนือหัว Player สูงขึ้นมา 50 หน่วย
//                color: #red 
//                font: font("Default", 24, #bold) // ปรับขนาดให้ใหญ่ขึ้นเพื่อให้เห็นชัด
//                perspective: true;
//        }
//    }
//}





//display point_player parent:test {
//    chart "Player Scores Comparison" type: histogram background: #white {
//        // วาดแท่งคะแนนของแต่ละ player โดยใช้ชื่อ (name) เป็นแกน X และ score เป็นแกน Y
//        data "Scores" value: unity_player collect each.score 
//             legend: "Score" 
//             color: #blue;
//    }
//}



display point_player1 parent:test {
    chart "Player Scores Comparison" type: histogram background: #white {
        // แกน X = ชื่อผู้เล่น (list of strings)
        // แกน Y = คะแนนของผู้เล่น (list of numbers)
        datalist (unity_player collect each.name) 
                 value: (unity_player collect each.score) 
                 color: [#blue, #red, #green, #orange]; // ใส่สีแยกตามคนได้
    }
}


//display point_player parent:test {
//    chart "Player Scores Comparison" type: histogram background: #white {
//        // ใช้ datalist เพื่อดึง name มาเป็นแกน X และ score เป็นแกน Y
//        // วิธีนี้จะทำให้แยกเป็นแท่งใครแท่งมัน ไม่เป็นบล็อกหนาอันเดียว
//        datalist (unity_player collect each.name) 
//                 value: (unity_player collect each.score) 
//                 color: [#blue]; 
//    }
//}



//display point_player parent:test {
//    chart "Player Scores Comparison" type: histogram background: #white {
//        // ใช้ datalist เพื่อดึงชื่อ (IP) มาเป็นแกน X และคะแนนเป็นแกน Y
//        // วิธีนี้จะแยกแท่งให้โดยอัตโนมัติ ไม่เป็นบล็อกรวม
//        datalist (unity_player collect each.name) 
//                 value: (unity_player collect each.score) 
//                 color: [#blue]; 
//    }
//}





//display point_player parent:test {
//    chart "Player Scores Comparison" type: histogram background: #white {
//        // เปลี่ยนจาก legend: "Score" เป็นการดึง name ของแต่ละ object มาแสดง
//        data "Scores" value: unity_player collect each.score 
//             legend: unity_player collect each.name 
//             color: #blue;
//    }
//}





//display point_player parent:test {
//    chart "Player Scores Comparison" type: histogram background: #white {
//        // ใช้ loop 'datalist' เพื่อสร้างแท่งคะแนนแยกตามชื่อผู้เล่นแต่ละคน
//        datalist unity_player collect each.name 
//                 value: unity_player collect each.score 
//                 color: [#blue]; 
//    }
//}
//
//
//	
	
		
	}
	
	
	
	

	
	
	
	
	
	
	
}
