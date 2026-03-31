model GamaToUnityUDP_Multi

global skills: [network] {
    // กำหนดขนาดพื้นที่เป็น 50x50
    geometry shape <- envelope(10.0); 
    
    int unity_port <- 9876;
    string unity_url <- "localhost";
    
    init {
        do connect to: unity_url protocol: "udp_emitter" port: unity_port;
        
        
        // สร้าง List ของตำแหน่งที่ต้องการ (ต้องมีจำนวนเท่ากับหรือมากกว่าจำนวน agent)
    list<point> person_locations <- [{2.0, 3.0}, {8.0, 5.0}, {4.0, 9.0}];
  	list<float> person_rotations <- [45, 200, 270];
    list<point> dog_locations <- [{1.0, 1.0}, {9.0, 2.0}];    
        
        // เมื่อแผนที่เล็กลง (50x50) 
        // สุ่มตำแหน่งเริ่มต้นให้กระจายทั่วพื้นที่ใหม่
        create person number: 3 {
//            location <- any_location_in(shape);
			//location <- {5.0, 7.0};
			location <- person_locations[int(self)];
			// กำหนดตัวแปร heading ในตัว person (เป็นตัวแปรพื้นฐานของ GAMA)
            heading <- float(person_rotations[int(self)]);
        } 
         create dog number: 2 {
            //location <- any_location_in(shape);
         //   location <- {1.0, 2.0};
         location <- dog_locations[int(self)];
        } 
        
        
    }

   reflex send_bulk_data {
        string all_agents_data <- "";
        
        // รวบรวมข้อมูลของ person
        loop h over: person {
            all_agents_data <- all_agents_data + string(h.name) + "," + string(h.location.x) + "," + string(h.location.y) +  ","  + string(h.heading) +"|";
        }
        
        // รวบรวมข้อมูลของ dog เพิ่มเข้าไป
        loop d over: dog {
            all_agents_data <- all_agents_data + string(d.name) + "," + string(d.location.x) + "," + string(d.location.y) + "|";
        }
        
        // ส่งก้อนข้อมูลทั้งหมด (ทั้งคนและหมา) ไปใน Packet เดียว
        do send contents: all_agents_data;
        
        write "Sending All: " + all_agents_data;
    }
    
}

species person {
    // ต้องประกาศตัวแปรไว้ที่นี่ก่อน
    float heading; 

    aspect default {
        // ตอนนี้จะสามารถใช้ rotate: heading ได้แล้ว
        draw triangle(0.5) color: #red rotate: heading;
    }
}

species player {
    // ต้องประกาศตัวแปรไว้ที่นี่ก่อน
    float heading; 

    aspect default {
        // ตอนนี้จะสามารถใช้ rotate: heading ได้แล้ว
        draw triangle(0.5) color: #black rotate: heading;
    }
}

species dog {
    aspect default {
        draw circle(0.1) color: #blue; // ปรับขนาดวงกลมให้เล็กลงตามขนาดแผนที่
    }
}

experiment Main type: gui {
    output {
        display "View" {
            // ปรับขนาดหน้าจอแสดงผลให้พอดีกับข้อมูล
            species person;
            species dog;
            
        }
    }
}