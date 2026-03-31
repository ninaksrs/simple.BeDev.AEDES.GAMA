model Dengue_Mosquito_Simple

global {
    int init_eggs <- 50;
    int init_people <- 20;

    float egg_hatch_rate <- 0.8;      
    float larva_survive_rate <- 0.7;  
    float bite_rate <- 0.3;           
    float infect_rate <- 0.4;         

    init {
        create egg number: init_eggs;
        create person number: init_people;
    }
}


species Puddleinthebucket{}



species egg {
    int age <- 0;

    // แก้ไข: เพิ่มส่วนกำหนดรูปร่าง (Aspect)
    aspect default {
        draw circle(0.5) color: #red;
    }

    reflex grow {
        age <- age + 1;
        if (age >= 2) {   
            // แก้ไข: ใช้ flip() เพื่อเช็คความน่าจะเป็น
            if (flip(egg_hatch_rate)) {
                create larva;
            }
            // แก้ไข: ใช้ 'do die' เพื่อลบ agent
            do die;
        }
    }
}

species larva {
    int age <- 0;

    // แก้ไข: เพิ่มส่วนกำหนดรูปร่าง
    aspect default {
        draw circle(0.8) color: #green;
    }

    reflex grow {
        age <- age + 1;
        if (age >= 5) {   
            if (flip(larva_survive_rate)) {
                create mosquito;
            }
            do die;
        }
    }
}

species mosquito {
    bool infected <- false;
    // แก้ไข: flip(0.5) คือโอกาส 50% ที่จะเป็นจริง
    bool female <- flip(0.5);  

    // แก้ไข: เพิ่มส่วนกำหนดรูปร่าง
    aspect default {
        // วาดสามเหลี่ยม สีแดงถ้าติดเชื้อ สีดำถ้าไม่ติด
        draw triangle(1.5) color: infected ? #red : #black;
    }

    reflex bite_people {
        // แก้ไข: ใช้ flip() แทน rnd_float
        if (female and flip(bite_rate)) {
            person p <- one_of(person);
            if (p != nil) {
                if (infected and flip(infect_rate)) {
                    p.infected <- true;
                }
                // ถ้ายุงไปกัดคนที่มีเชื้อ ยุงก็จะรับเชื้อมา
                if (p.infected) {
                    infected <- true;
                }
            }
        }
    }
}

species person {
    bool infected <- false;
    
    // แก้ไข: เพิ่มส่วนกำหนดรูปร่าง
    aspect default {
        draw circle(2.0) color: infected ? #red : #blue;
    }
}

experiment main type: gui {
    output {
        display main_display {
            species egg aspect: default;
            species larva aspect: default;
            species mosquito aspect: default;
            species person aspect: default;
        }
    }
}