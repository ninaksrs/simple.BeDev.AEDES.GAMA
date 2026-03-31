model GamaToUnityUDP_Multi

global skills: [network] {
    // กำหนดขนาดพื้นที่เป็น 50x50
    geometry shape <- envelope(1000.0 
    	
    ); 
  

	image_file map_image  <- image_file("../includes/T_map_1.png");


init {
  
    // --- ส่วนที่เหลือ (การสร้าง Agent) ถูกต้องแล้วครับ ---
    
    list<point> home_locations <- [{300.5, 200.1}, {300.2, 450.8}, {350.5, 875.9}, {620.5, 875.2}, {920.0, 400.0}];
    list<float> home_rotations <- [270, 360, 180, 0, 60];
    list<point> dog_locations <- [{1.0, 1.0}, {9.0, 2.0}];    
    
    create home number: 5 {
        location <- home_locations[int(self)];
        heading <- float(home_rotations[int(self)]);
    } 
    
    create car number: 1 {
        location <- {7.0, 8.0};
        heading <- float(330);
    } 
    
    create dog number: 2 {
        location <- dog_locations[int(self)];
    } 
    
    create map_agent number: 1 {
        location <- {500, 500.0, -0.5};
    }
}


}

species home {
    // ต้องประกาศตัวแปรไว้ที่นี่ก่อน
    float heading; 

    aspect default {
        // ตอนนี้จะสามารถใช้ rotate: heading ได้แล้ว
        draw triangle(50.5) color: #red rotate: heading;
    }
}


species car {
    // ต้องประกาศตัวแปรไว้ที่นี่ก่อน
    float heading; 

    aspect default {
        // ตอนนี้จะสามารถใช้ rotate: heading ได้แล้ว
        draw triangle(0.5) color: #blue rotate: heading;
    }
}






species map_agent {
    aspect default {
        // 3. วาดรูปให้ขนาดเท่ากับ envelope (50x50)
        draw map_image size: {1000.0, 1000.0};
        
        // วาดขอบสีแดงล้อมรอบ agent เพื่อเช็คตำแหน่ง
        //draw square(1.0) color: #red;
    }
}



species dog {
    aspect default {
        draw circle(0.1) color: #blue; // ปรับขนาดวงกลมให้เล็กลงตามขนาดแผนที่
    }
}

experiment Main type: gui {
    output {
        display "test" {
            // ปรับขนาดหน้าจอแสดงผลให้พอดีกับข้อมูล
            species map_agent aspect: default;
            species home;
            species car;
            species dog;
           
        }
    }
}








