model Dengue_Mosquito_Simple

global {
	
    //geometry shape <- square(100#m);
    int environment_size <- 100#m;
    geometry shape <- cube(environment_size);
    float obj_radius <- 0.6;   // 👈 ใส่ตรงนี้
    float min_dist <- obj_radius * 2.0;   // ระยะขั้นต่ำไม่ให้ทับ
    init {
    create home number: 1 { location <- {50.0, 70.0}; }
    create Backyard number: 1 { location <- {50.0, 25.0}; }

   // 1. Create Pools first
    create pool number: 5 {
        location <- any_location_in(first(Backyard).shape - obj_radius);
    }

    // 2. Create Flowers (Check against pools)
    create flower number: 10 {
        location <- any_location_in(first(Backyard).shape - obj_radius);
        loop while: not empty((flower + pool) overlapping self) {
            location <- any_location_in(first(Backyard).shape - obj_radius);
        }
    }

    // 3. Create Frogs (Check against pools + flowers)
    create frog number: 10 {
        location <- any_location_in(first(Backyard).shape - obj_radius);
        loop while: not empty((flower + pool + frog) overlapping self) {
            location <- any_location_in(first(Backyard).shape - obj_radius);
        }
    }

    // 4. Create Persons (Check against EVERYTHING)
    create person number: 5 {
       // location <- any_location_in(first(Backyard).shape - obj_radius);
        loop while: not empty((flower + pool + frog + person) overlapping self) {
            location <- any_location_in(first(Backyard).shape - obj_radius);
        }
    }

    // Mosquitoes can overlap usually, so they stay simple
    create male_mosquito number: 20 { location <- any_location_in(first(Backyard)); }
    create player_female_mosquito number: 1 { location <- any_location_in(first(Backyard)); }
}
}

species home {
    aspect default {
        // วาดสี่เหลี่ยมสีดำ ขนาด 10 เมตร (ปรับขนาดให้เห็นชัดขึ้น)
        draw rectangle(80.0, 35.0) color: #black border: #black;
    }
}



species flower {
	geometry shape <- circle(1.1);
    aspect default {
        // วาดสี่เหลี่ยมสีดำ ขนาด 10 เมตร (ปรับขนาดให้เห็นชัดขึ้น)
        draw circle(1.1) color: #pink border: #black;
    }
}


species pool {
	geometry shape <- circle(1.1);
    aspect default {
    	
        // วาดสี่เหลี่ยมสีดำ ขนาด 10 เมตร (ปรับขนาดให้เห็นชัดขึ้น)
        draw circle(1.1) color: #blue border: #black;
    }
}


species frog {
    geometry shape <- circle(1.1);
    float eat_radius <- 2.0; 
    
    // ตัวแปรควบคุมการกิน
    int last_eat_cycle <- -25; // ค่าเริ่มต้น (ติดลบเพื่อให้กินตัวแรกได้ทันที)
    bool is_hungry <- true update: (cycle - last_eat_cycle >= 25); 

    reflex eat_mosquitoes when: is_hungry {
        // ตรวจสอบยุงในระยะ
        list<male_mosquito> targets <- male_mosquito at_distance eat_radius;
        list<player_female_mosquito> player_targets <- player_female_mosquito at_distance eat_radius;

        // รวมรายการยุงที่อยู่ใกล้
        agent victim <- one_of(targets + player_targets);

        if (victim != nil) {
            ask victim { do die; }
            
            // --- หัวใจสำคัญตรงนี้ ---
            last_eat_cycle <- cycle; // บันทึกรอบที่กินล่าสุดทันที
            write "Frog ate one! Now waiting for 5 seconds...";
        }
    }

    aspect default {
 // กบตัวจริง
    rgb frog_color <- is_hungry ? #green : #gray;
    draw circle(1.1) color: frog_color border: #black;
    
    // วาดรัศมีการกิน (วงกลมจางๆ)
    // เปลี่ยนจาก empty: false เป็นการใช้ alpha (ความโปร่งใส) แทน
    draw circle(eat_radius) color: rgb(0, 255, 0, 40);
    }
}

//species player_female_mosquito skills: [moving] {
//    // เก็บพิกัดเป้าหมาย (เริ่มที่ตำแหน่งเกิดของตัวเอง)
//    point target_loc <- location;
//    float speed <- 1.0;
//background: rgb(10, 40, 55)
//    reflex move_to_click {
//        // ถ้ายุงยังไม่อยู่ที่จุดเป้าหมาย (มีระยะห่าง > 0.5 เมตร) ให้บินไป
//        if (self distance_to target_loc > 0.5) {
//            do goto target: target_loc speed: speed;
//        }
//    }
//
//    aspect default {
//        draw triangle(2.5) color: #pink rotate: heading;
//        
//        // (Optional) วาดเส้นประหรือจุดเล็กๆ ให้รู้ว่ากำลังบินไปที่ไหน
//        if (self distance_to target_loc > 0.5) {
//            draw line([location, target_loc]) color: #pink;
//        }
//    }
//}






species player_female_mosquito skills: [moving] control: fsm {
    float speed <- 1.2;
    
    // ตัวแปรเก็บพิกัดเป้าหมายจากการคลิก
    point target_loc <- location;

    // เคลื่อนที่ไปจุดที่คลิกเสมอไม่ว่าจะอยู่สถานะไหน
    reflex move_to_click {
        if (self distance_to target_loc > 0.5) {
            do goto target: target_loc speed: speed;
        }
    }

    // 1. เริ่มต้น: หาน้ำหวานจากดอกไม้
    state finding_sugar initial: true {
        enter { write "Task 1: Go to a Flower for sugar!"; }
        
        // ใช้ transition when แทนการใส่ใน if
        transition to: finding_mate when: !empty(flower at_distance 2.0);
    }

    // 2. ไปหาตัวผู้เพื่อรับน้ำเชื้อ
    state finding_mate {
        enter { write "Task 2: Find a Male mosquito!"; }
        
        transition to: finding_blood when: !empty(male_mosquito at_distance 2.0);
    }

    // 3. ไปกินเลือดคน
    state finding_blood {
        enter { write "Task 3: Find a Person to bite!"; }
        
        transition to: laying_eggs when: !empty(person at_distance 2.0);
    }

    // 4. ไปวางไข่ในบ่อน้ำ
    state laying_eggs {
        enter { write "Task 4: Go to the Pool to lay eggs!"; }
        
        // เมื่อวางไข่เสร็จ ให้กลับไปหิวน้ำหวานใหม่ (วน Loop)
        transition to: finding_sugar when: !empty(pool at_distance 2.0);
    }

    aspect default {
        // เปลี่ยนสีตาม State ปัจจุบัน
        rgb status_color <- #pink;
        if (state = "finding_mate") { status_color <- #orange; }
        if (state = "finding_blood") { status_color <- #red; }
        if (state = "laying_eggs") { status_color <- #blue; }
        
        draw triangle(2.5) color: status_color rotate: heading;
        
        // วาดชื่อสถานะกำกับไว้บนตัวยุง
        draw state color: #black size: 3 at: {location.x - 2, location.y - 3};
        
        if (self distance_to target_loc > 0.5) {
            draw line([location, target_loc]) color: status_color;
        }
    }
}






species male_mosquito skills: [moving] { // เพิ่ม skill moving เพื่อให้ยุงขยับได้
    flower my_target; // ตัวแปรเก็บดอกไม้ที่ยุงสนใจ

    init {
        // เมื่อเกิดมา ให้สุ่มเลือกดอกไม้เป้าหมาย 1 ดอก
        my_target <- one_of(flower);
    }

    reflex fly_around {
        // ถ้ายุงอยู่ห่างจากดอกไม้เกิน 3 เมตร ให้บินเข้าไปหา
        if (self distance_to my_target > 3.0) {
            do goto target: my_target speed: 0.5;
        } 
        // ถ้าเข้าใกล้แล้ว ให้บินสุ่มวนเวียน (Wander) อยู่รอบๆ ดอกไม้นั้น
        else {
            do wander amplitude: 45.0 speed: 0.2 bounds: my_target.shape + 5.0;
        }
    }

    aspect default {
        draw triangle(2.0) color: #blue;
    }
}

species person {
	geometry shape <- circle(1.5);
    aspect default {
        draw circle(1.5) color: #yellow;
    }
}




species Backyard {
    // กำหนดให้รูปร่างพื้นฐานของสายพันธุ์นี้เป็นสี่เหลี่ยมตามขนาดที่ต้องการ
    geometry shape <- rectangle(80.0, 35.0); 

    aspect default {
        // ใช้ draw shape เพื่อวาดตามขอบเขตพื้นที่จริง
        draw shape color: #green border: #black;
    }
}


experiment main type: gui {
    output {
        display main_display type: 2d background: rgb(10, 40, 55){
           // เมื่อมีการกดเมาส์ (mouse_down) 
            // ให้ไปบอกยุงตัวเมียทุกตัว (ซึ่งมีตัวเดียว) ให้เปลี่ยน target_loc เป็นจุดที่คลิก
            event mouse_down action: {
                ask player_female_mosquito {
                    target_loc <- #user_location;
                }
            };

            species Backyard;
            species home;
            species frog;
            species pool;
            species flower;
            species person;
            species male_mosquito;
            species player_female_mosquito;
            			graphics "env" {
				draw cube(environment_size) color: #black wireframe: true;
			}
        }
        
        
        
                display main_display type: 3d background: rgb(10, 40, 55){
        		camera 'default' location: {-89.9704,145.5689,125.2091} target: {117.2908,13.529,0.0};
           // เมื่อมีการกดเมาส์ (mouse_down) 
            // ให้ไปบอกยุงตัวเมียทุกตัว (ซึ่งมีตัวเดียว) ให้เปลี่ยน target_loc เป็นจุดที่คลิก
            event mouse_down action: {
                ask player_female_mosquito {
                    target_loc <- #user_location;
                }
            };

            species Backyard;
            species home;
            species frog;
            species pool;
            species flower;
            species person;
            species male_mosquito;
            species player_female_mosquito;
            			graphics "env" {
				draw cube(environment_size) color: #black wireframe: true;
			}
        }
        
   display "First person" type: opengl background: rgb(10, 40, 55){
    // กำหนดกล้องให้ติดตามยุงตัวเมียแบบ Real-time
    camera 'default' 
        location: {
            first(player_female_mosquito).location.x, 
            first(player_female_mosquito).location.y, 
            3.0 // ความสูงจากพื้น (Z)
        } 
        target: {
            // มองไปข้างหน้าตามทิศทาง (Heading) ที่ยุงหันไป
            first(player_female_mosquito).location.x + cos(first(player_female_mosquito).heading) * 5, 
            first(player_female_mosquito).location.y + sin(first(player_female_mosquito).heading) * 5, 
            0.0 // มองลงพื้นเล็กน้อย
        }
        dynamic: true; // <--- สำคัญมาก: บังคับให้กล้องขยับตามยุงทุกเฟรม

    // วาด Object ต่างๆ เพื่อให้เห็นว่ากล้องเคลื่อนที่
    species Backyard;
    species home;
    species frog;
    species pool;
    species flower;
    species person;
    species male_mosquito;
    species player_female_mosquito;
}
        
        
        
    }
    
    
    

}



//experiment Tuto3D type: gui {
//	        output {
//        display main_display type: 3d background: rgb(10, 40, 55){
//        		camera 'default' location: {-89.9704,145.5689,125.2091} target: {117.2908,13.529,0.0};
//           // เมื่อมีการกดเมาส์ (mouse_down) 
//            // ให้ไปบอกยุงตัวเมียทุกตัว (ซึ่งมีตัวเดียว) ให้เปลี่ยน target_loc เป็นจุดที่คลิก
//            event mouse_down action: {
//                ask player_female_mosquito {
//                    target_loc <- #user_location;
//                }
//            };
//
//            species Backyard;
//            species home;
//            species frog;
//            species pool;
//            species flower;
//            species person;
//            species male_mosquito;
//            species player_female_mosquito;
//        }
//    }
//
//}