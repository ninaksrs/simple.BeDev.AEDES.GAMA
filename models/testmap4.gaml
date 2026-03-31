model GamaToUnityUDP_Multi

global skills: [network] {
    // กำหนดขนาดพื้นที่เป็น 50x50
    geometry shape <- envelope(20.0 
    	
    ); 
  
    int port <- 9875;
    int unity_port <- 9876;
   //string unity_url <- "localhost";
   string unity_url <- "192.168.0.255";
   //  string unity_url <- "10.215.211.225";
 
	//image_file map_image <- image_file("../includes/WhatsApp Image 2026-03-12 at 16.12.22.jpeg");

	image_file map_image  <- image_file("../includes/T_map_1.png");




//    init {
//    	// GAMA จะยิงข้อมูลออกไปหาทุกเครื่องที่ต่อ Wi-Fi วงเดียวกัน
//        do connect to: unity_url protocol: "udp_emitter" port: unity_port;
//    	
//    	 // สร้าง Manager ตัวเดียวเพื่อรอรับข้อความจากทุก Client
//        create UnityManager number: 1 {
//            do connect to: "localhost" protocol: "udp_server" port: port;
//        }
//    	
//    	
//        do connect to: unity_url protocol: "udp_emitter" port: unity_port;
//        
//        
//        // สร้าง List ของตำแหน่งที่ต้องการ (ต้องมีจำนวนเท่ากับหรือมากกว่าจำนวน agent)
//    list<point> home_locations <- [{5.5, 3.1}, {18.2, 8.8}, {7.5, 17.9}, {12.5, 18.2}, {6.0, 9.0}];
//  	list<float> home_rotations <- [270, 360, 180, 0, 60];
//    list<point> dog_locations <- [{1.0, 1.0}, {9.0, 2.0}];    
//        
//        // เมื่อแผนที่เล็กลง (50x50) 
//        // สุ่มตำแหน่งเริ่มต้นให้กระจายทั่วพื้นที่ใหม่
//        create home number: 5 {
////            location <- any_location_in(shape);
//			//location <- {5.0, 7.0};
//			location <- home_locations[int(self)];
//			// กำหนดตัวแปร heading ในตัว person (เป็นตัวแปรพื้นฐานของ GAMA)
//            heading <- float(home_rotations[int(self)]);
//        } 
//        
//        
//        
//             create car number: 1 {
////            location <- any_location_in(shape);
//			location <- {7.0, 8.0};
//			//location <- home_locations[int(self)];
//			// กำหนดตัวแปร heading ในตัว person (เป็นตัวแปรพื้นฐานของ GAMA)
//            heading <- float(330);
//        } 
//        
//        
//        
//        
//         create dog number: 2 {
//            //location <- any_location_in(shape);
//         //   location <- {1.0, 2.0};
//         location <- dog_locations[int(self)];
//        } 
//        
//        
//       
//        create map_agent number: 1 {
//            // วางไว้ที่จุดกึ่งกลางของ envelope (25, 25)
//            location <- {10.0, 10.0, -0.5};
//        }
//        
//    }






init {
    // 1. เชื่อมต่อไปยัง Unity (ใช้เลข Broadcast .255 ที่เราหาได้)
    // ตรงนี้ทำหน้าที่เป็น "ตัวส่ง" (Emitter)
    do connect to: unity_url protocol: "udp_emitter" port: unity_port;
    
    // 2. สร้าง Manager เพื่อรอรับข้อมูลจาก Unity ทุกเครื่อง
    // เปลี่ยนจาก "localhost" เป็น "0.0.0.0" เพื่อให้รับข้อมูลจาก IP อื่นๆ ได้
    create UnityManager number: 1 {
        do connect to: "0.0.0.0" protocol: "udp_server" port: port;
    }
    
    // --- ส่วนที่เหลือ (การสร้าง Agent) ถูกต้องแล้วครับ ---
    
    list<point> home_locations <- [{5.5, 3.1}, {18.2, 8.8}, {7.5, 17.9}, {12.5, 18.2}, {6.0, 9.0}];
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
        location <- {10.0, 10.0, -0.5};
    }
}






   reflex send_bulk_data {
        string all_agents_data <- "";
        
        // รวบรวมข้อมูลของ home
        loop h over: home {
            all_agents_data <- all_agents_data + string(h.name) + "," + string(h.location.x) + "," + string(h.location.y) +  ","  + string(h.heading) +"|";
        }
        
        
          // รวบรวมข้อมูลของ car
        loop h over: car {
            all_agents_data <- all_agents_data + string(h.name) + "," + string(h.location.x) + "," + string(h.location.y) +  ","  + string(h.heading) +"|";
        }
        
        
           // รวบรวมข้อมูลของ map เพิ่มเข้าไป
        loop h over: map_agent {
            all_agents_data <- all_agents_data + string(h.name) + "," + string(h.location.x) + "," + string(h.location.y) + "," + string(h.location.z)+ "|";
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

species home {
    // ต้องประกาศตัวแปรไว้ที่นี่ก่อน
    float heading; 

    aspect default {
        // ตอนนี้จะสามารถใช้ rotate: heading ได้แล้ว
        draw triangle(0.5) color: #red rotate: heading;
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





// Species สำหรับจัดการการรับข้อมูล (เปรียบเสมือน Server)
species UnityManager skills: [network] {
    
    reflex receive_all_clients {
        loop while: has_more_message() {
            message msg <- fetch_message();
            string data <- string(msg.contents);
            list<string> vals <- data split_with ";";
            
            if (length(vals) >= 5) {
                int incoming_id <- int(vals[4]);
                
                // ค้นหาว่ามี Agent ID นี้อยู่หรือยัง
                UnityReceiver target <- first(UnityReceiver where (each.u_id = incoming_id));
                
                // ถ้ายังไม่มี ให้สร้างใหม่
                if (target = nil) {
                    create UnityReceiver {
                        u_id <- incoming_id;
                        target <- self;
                    }
                }
                
                // อัปเดตข้อมูลให้ Agent ตัวนั้นๆ
//                ask target {
//                    unity_ip <- vals[0];
//                    location <- {float(vals[1]), float(vals[2]), float(vals[3])};
//                    last_update_cycle <- cycle;
//                }



// ภายใน species UnityManager -> reflex receive_all_clients
// ภายใน species UnityManager -> reflex receive_all_clients
ask target {
    unity_ip <- vals[0];
    
    float valX <- float(vals[1]);
    float valY <- float(vals[2]);
    float valZ <- float(vals[3]);

    // สมมติว่า Unity ส่งค่ามาในช่วง -5 ถึง 5 
    // เราต้องบวก 5 เพื่อให้กลายเป็น 0 ถึง 10 ใน GAMA
    // หรือถ้า Unity ส่งค่ามา 0-100 เราต้องหาร 10
    
    // ตัวอย่างการทำ Normalization (ปรับให้เข้ากับ envelope 10.0):
    float finalX <- (-valX + 0.0); // ปรับตาม offset จริงของ Unity
    float finalY <- (valZ + 0.0); // Unity Z มักเป็น GAMA Y
    
    // ใช้ฟังก์ชัน copy_between เพื่อบังคับให้อยู่ใน 0-10 เสมอ (ป้องกันหลุดขอบ)
    location <- {
        max(0.0, min(20.0, finalX)), 
        max(0.0, min(20.0, finalY)), 
        valY // แกนความสูง
    };
    
    last_update_cycle <- cycle;
}




//ask target {
//    unity_ip <- vals[0];
//    
//    // รับค่าจาก Unity (สมมติ: index 1=X, 2=Y, 3=Z)
//    float valX <- float(vals[1]);
//    float valY <- float(vals[2]); 
//    float valZ <- float(vals[3]);
//
//    // การตั้งค่าแกนเพื่อให้ตรงกับ Unity และอยู่ตรงกลาง GAMA:
//    // 1. แกน X: 50 + valX (ถ้าสลับซ้ายขวาให้ใช้ 50 - valX)
//    // 2. แกน Y: 50 - valY (การใส่ - หน้า valY จะเป็นการสลับ บน-ล่าง)
//    // 3. แกน Z: ใช้ค่าความสูงจาก Unity (มักจะเป็น index 3 หรือ valZ)
//    
//    location <- {50 + valX, 50 - valY, valZ}; 
//    
//    last_update_cycle <- cycle;
//}



            }
        }
    }
}

// Species สำหรับตัวแทนเครื่อง Unity แต่ละเครื่อง
//species UnityReceiver {
//    int u_id;
//    string unity_ip;
//    int last_update_cycle;
//
//// ส่วนนี้คือส่วนที่ใช้วาดรูปทรง 3D
//    aspect default {
//        draw sphere(2) color: #blue at: location + {50,50,3} ;  //<-- ลบบรรทัดนี้ออก หรือใส่ // ข้างหน้า
//        
//        // ถ้ายังอยากให้เห็นตัวเลข ID ลอยอยู่บนแผนที่ ให้เก็บส่วนนี้ไว้
//        draw "ID: " + u_id at: location + {0,0,3} color: #black font: font("Arial", 12);
//    }
//}
species UnityReceiver {
    int u_id;
    string unity_ip;
    int last_update_cycle;

    aspect default {
        // วาดที่ตำแหน่ง location จริงๆ (ไม่ต้องบวก 50 เพราะ envelope เราแค่ 10)
        draw sphere(0.3) color: #blue; 
        
        // วาด ID ไว้เหนือตัว Agent เล็กน้อย
        draw "ID: " + u_id at: location + {0, 0, 0.5} color: #white font: font("Arial", 8);
    }
}




species map_agent {
    aspect default {
        // 3. วาดรูปให้ขนาดเท่ากับ envelope (50x50)
        draw map_image size: {20.0, 20.0};
        
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
        display "View" {
            // ปรับขนาดหน้าจอแสดงผลให้พอดีกับข้อมูล
            species map_agent aspect: default;
            species home;
            species car;
            species dog;
             species UnityReceiver aspect: default;
        }
    }
}











experiment TestUnity type: gui {
    output {
        // ใช้ 3D display เพื่อให้เห็นแกน Z จาก Unity
        display "UnityMonitor" type: 3d background: #black {  
            
            // 1. ตั้งกล้องให้มองลงมาตรงๆ (Top-down) เห็นพื้นที่ทั้งหมด
            // ปรับ location Z (15) ให้พอดีกับขนาดพื้นที่ (10)
            camera 'default' location: {5.0, 5.0, 15.0} target: {5.0, 5.0, 0.0};

            // 2. วาดขอบเขตของพื้นที่ (Shape)
            graphics "Bounds" {
                draw world.shape wireframe: true color: #white;
                // วาดพื้นหลังพื้นผิว (Optional)
                draw world.shape color: rgb(30, 30, 30); 
            }

            // 3. วาด Agent ให้อยู่ในพื้นที่
            // สำคัญ: ใน UnityManager คุณต้องแน่ใจว่าคำนวณ location ให้อยู่ในช่วง {0,0} ถึง {10,10}

            
            
            
            species UnityReceiver aspect: default;
            species home aspect: default;
            species dog aspect: default;

            // 4. ส่วนของ UI Overlay (ข้อมูลสถานะ)
            // ใช้พิกัดคงที่เทียบกับหน้าจอเพื่อให้ตัวหนังสือไม่ขยับตามกล้อง
            graphics "StatusOverlay" {
                float overlay_x <- 0.2; // ตำแหน่งเริ่มด้านซ้าย
                
                draw "UNITY AGENTS STATUS" at: {overlay_x, 0.5} color: #yellow font: font("SansSerif", 14, #bold);
                
                loop i from: 1 to: 4 {
                    UnityReceiver target <- UnityReceiver first_with (each.u_id = i);
                    
                    string display_text <- "ID " + i + ": ";
                    rgb status_color <- #gray;
                    
                    if (target != nil) {
                        bool is_alive <- (cycle - target.last_update_cycle) < 50;
                        
                        // แสดงพิกัดจริงที่ Agent อยู่ใน GAMA
                        string pos_text <- " [X:" + (target.location.x with_precision 1) + 
                                           " Y:" + (target.location.y with_precision 1) + "]";
                        
                        display_text <- display_text + pos_text;
                        status_color <- is_alive ? #green : #red;
                    } else {
                        display_text <- display_text + "OFFLINE";
                    }

                    draw display_text 
                        at: {overlay_x, 1.0 + (i * 0.8)} 
                        color: status_color 
                        font: font("Monospaced", 10, #bold);
                }
            }
        }
    }
}