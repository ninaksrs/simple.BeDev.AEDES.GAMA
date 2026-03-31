model TestMapImage

global {
    // 1. กำหนดขนาดพื้นที่ให้พอดีกับรูป (เช่น 50x50)
    geometry shape <- envelope(10.0);
    
    // 2. เช็คชื่อไฟล์และ Path ให้ถูกต้อง (แนะนำให้เปลี่ยนชื่อไฟล์ให้สั้นและไม่มีเว้นวรรคจะชัวร์ที่สุด)
   
	image_file map_image <- image_file("../includes/WhatsApp Image 2026-03-12 at 16.12.22.jpeg");

    init {
        create map_agent number: 1 {
            // วางไว้ที่จุดกึ่งกลางของ envelope (25, 25)
            location <- {5.0, 5.0};
        }
    }
}

species map_agent {
    aspect default {
        // 3. วาดรูปให้ขนาดเท่ากับ envelope (50x50)
        draw map_image size: {10.0, 10.0};
        
        // วาดขอบสีแดงล้อมรอบ agent เพื่อเช็คตำแหน่ง
        //draw square(1.0) color: #red;
    }
}

experiment Main type: gui {
    output {
        // ใช้ display 2D ธรรมดาก่อนเพื่อความชัวร์
      //  display "SimpleView" {
        	display "UnityMonitor" type: 3d background: #black {
            species map_agent aspect: default;
        }
    }
}