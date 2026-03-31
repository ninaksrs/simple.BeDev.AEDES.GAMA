model test_unity_link

global {
    int port_to_unity <- 8888;
    int environment_size <- 100;
    geometry shape <- cube(environment_size);
    
    init {
        create home number: 1;
    }
}

species home skills: [network] {
    
    bool is_connected <- false;
    string my_connection <- "unity_link";

    reflex sync_to_unity {
        // 1. เชื่อมต่อครั้งแรกครั้งเดียว
        if (is_connected = false) {
            // ใช้โครงสร้างพื้นฐาน: ระบุ IP และ Port แยกกันชัดเจน
            do connect to: "127.0.0.1" protocol: "udp" port: port_to_unity with_name: my_connection;
            is_connected <- true;
            write "GAMA: Connection initialized.";
        }
        
        // 2. เตรียมข้อมูลตำแหน่ง
        string msg_data <- "" + location.x + "," + location.y + "," + location.z;
        
        // 3. ส่งข้อมูลผ่านชื่อ connection
        do send contents: msg_data to: my_connection;
        
        // แสดง Log ใน GAMA Console
        write "GAMA Sent: " + msg_data;
    }

    aspect default {
        draw box(10, 10, 10) color: #gray border: #black; 
    }
}

experiment main type: gui {
    output {
        display map type: opengl {
            graphics "floor" { draw square(environment_size) color: #lightgray; }
            species home;
        }
    }
}