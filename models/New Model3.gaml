//model Dengue_Mosquito_Simple
//
//global {
//    // ข้อมูลจากเอกสาร: วงจรชีวิตรวม 7-10 วัน
//    int egg_incubation_time <- 3; // ระยะไข่ 2-3 วัน
//    int larva_period <- 7;        // ระยะหนอนน้ำ 5-7 วัน
//    int pupa_period <- 2;         // ระยะดักแด้ 1-2 วัน
//    
//    // ข้อมูลอายุไขโดยสะเฉลี่ย
//    int male_lifespan <- 10;      // ยุงตัวผู้ 7-10 มื้
//    int female_lifespan <- 30;    // ยุงตัวแม่ 30 มื้
//    
//    init {
//        create Puddle_in_the_bucket number: 3; //3
//        create person number: 30; //30 
//        create flower number: 50; //50
//        // เริ่มต้นด้วยไข่ตามแหล่งน้ำ
//        create egg number: 20 { //20
//            location <- any(Puddle_in_the_bucket).location;
//        }
//    }
//}
//
//species Puddle_in_the_bucket {
//    aspect default {
//        draw circle(2) color: #blue;
//    }
//}
//
//species egg {
//    int age <- 0;
//    reflex development {
//        age <- age + 1;
//        if (age >= egg_incubation_time) {
//            create larva number: 1 { location <- myself.location; }
//            do die;
//        }
//    }
//    aspect default {
//        draw ellipse(0.6, 0.3) color: #gray;
//    }
//}
//
//species larva {
//    int age <- 0;
//    reflex growth {
//        age <- age + 1;
//        // หนอนน้ำลอกคราบ 4 ครั้ง
//        if (age >= larva_period) {
//            // อัดตาส่วนการเกิด 50% ต่อ 50%
//            if (flip(0.5)) { 
//                create male_mosquito { location <- myself.location; }
//            } else {
//                create female_mosquito { location <- myself.location; }
//            }
//            do die;
//        }
//    }
//    aspect default {
//        draw line([{0,0}, {0,1.5}]) color: #black;
//    }
//}
//
//species female_mosquito skills: [moving] {
//    int age <- 0;
//    bool has_mated <- false;
//    bool full_of_blood <- false;
//    
//    reflex fly {
//        do wander speed: 1.5;
//    }
//    
//    reflex feeding {
//        // ยุงตัวเมียกินน้ำหวานเป็นพลังงานก่อน
//        // และต้องการโปรตีนจากเลือดเพื่อสร้างไข่
//        person target <- (person closest_to self);
//        if (target != nil and self distance_to target < 2) {
//            full_of_blood <- true;
//        }
//    }
//
//    reflex aging {
//        age <- age + 1;
//        if (age >= female_lifespan) { do die; }
//    }
//    
//    aspect default {
//        // ยุงตัวเมียตัวใหญ่และหนักกว่า
//        draw triangle(2) color: full_of_blood ? #darkred : #red; 
//    }
//}
//
//species male_mosquito skills: [moving] {
//    int age <- 0;
//    
//    reflex fly {
//        // ยุงตัวผู้บินรวมกลุ่มเป็นฝูงใกล้แหล่งเพาะพันธุ์
//        do wander speed: 1.0;
//    }
//    
//    reflex feeding {
//        // ยุงตัวผู้กินแต่น้ำหวานจากเกสรดอกไม้
//        flower target <- (flower closest_to self);
//        if (target != nil and self distance_to target < 1.5) {
//            // ฟื้นฟูพลังงาน
//        }
//    }
//
//    reflex aging {
//        age <- age + 1;
//        if (age >= male_lifespan) { do die; }
//    }
//    
//    aspect default {
//        draw triangle(1.2) color: #green;
//    }
//}
//
//species person {
//    aspect default {
//        draw circle(2.5) color: #orange;
//    }
//}
//
//species flower {
//    aspect default {
//        // แก้ไข Error: ใช้ square หรือ circle แทน hex
//        draw square(1.5) color: #pink;
//    }
//}
//
//experiment main type: gui {
//    output {
//        // แสดงผลลัพธ์ผ่าน Monitor
//        monitor "จำนวนยุงตัวเมีย" value: length(female_mosquito);
//        monitor "จำนวนยุงตัวผู้" value: length(male_mosquito);
//        
//        display main_display {
//            species Puddle_in_the_bucket;
//            species flower;
//            species person;
//            species egg;
//            species larva;
//            species male_mosquito;
//            species female_mosquito;
//        }
//    }
//}

















model Dengue_Mosquito_Complete_Loop

global {
    // พารามิเตอร์จากเอกสาร
    int egg_incubation_time <- 3; // ระยะไข่ 2-3 วัน [cite: 6]
    int larva_period <- 7;        // ระยะหนอนน้ำ 5-7 วัน [cite: 8]
    int male_lifespan <- 10;      // ยุงตัวผู้ 7-10 วัน [cite: 3]
    int female_lifespan <- 30;    // ยุงตัวเมีย ~30 วัน [cite: 2]
    
    init {
        create Puddle_in_the_bucket number: 10;
        create person number: 5;
        create flower number: 20;
        // เริ่มต้นวงจรด้วยไข่ [cite: 5]
        create egg number: 10 {
            location <- any(Puddle_in_the_bucket).location;
        }
    }
}

species Puddle_in_the_bucket {
    aspect default { draw circle(2) color: #blue; }
}

species egg {
    int age <- 0;
    reflex development {
        age <- age + 1;
        if (age >= egg_incubation_time) {
            create larva number: 1 { location <- myself.location; }
            do die;
        }
    }
    aspect default { draw ellipse(0.6, 0.3) color: #gray; }
}

species larva {
    int age <- 0;
    reflex growth {
        age <- age + 1;
        if (age >= larva_period) {
            // อัตราส่วนการเกิด 50/50 [cite: 14]
            if (flip(0.5)) { create male_mosquito { location <- myself.location; } }
            else { create female_mosquito { location <- myself.location; } }
            do die;
        }
    }
    aspect default { draw line([{0,0}, {0,1.5}]) color: #black; }
}











// --- ยุงตัวเมีย: หัวใจของการแพร่พันธุ์ ---
species female_mosquito skills: [moving] {
    int age <- 0;
    float energy <- 1.0; 
    bool full_of_blood <- false;
    int digestion_timer <- 0;
    
    // พฤติกรรมหลัก: ตัดสินใจตามความต้องการ (Priority)
    reflex logic {
        // 1. ถ้าหิว (พลังงานต่ำ) -> ไปหาดอกไม้ (สีชมพู)
        if (energy < 0.4) {
            flower target_flower <- (flower closest_to self);
            if (target_flower != nil) {
                do goto target: target_flower.location speed: 1.5;
                if (self distance_to target_flower < 1.0) { energy <- 1.0; }
            }
        } 
        // 2. ถ้าพลังงานโอเค และ ท้องว่าง -> ไปหาคน (สีส้ม)
        else if (!full_of_blood) {
            person target_person <- (person closest_to self);
            if (target_person != nil) {
                do goto target: target_person.location speed: 1.5;
                if (self distance_to target_person < 1.5) { 
                    full_of_blood <- true; 
                    digestion_timer <- 0;
                }
            }
        } 
        // 3. ถ้ากินเลือดแล้ว และ พักจนไข่สุก -> ไปหาแหล่งน้ำ (สีฟ้า)
        else if (full_of_blood and digestion_timer >= 3) {
            Puddle_in_the_bucket home <- (Puddle_in_the_bucket closest_to self);
            if (home != nil) {
                do goto target: home.location speed: 1.5;
                if (self distance_to home < 1.5) {
                    create egg number: 10 { location <- myself.location; }
                    full_of_blood <- false;
                }
            }
        } 
        // 4. ถ้าไม่มีอะไรทำ -> บินว่อนอิสระ
        else {
            do wander speed: 1.2;
        }
    }

    reflex aging {
        age <- age + 1;
        energy <- energy - 0.05; // พลังงานลดลงเรื่อยๆ
        if (full_of_blood) { digestion_timer <- digestion_timer + 1; }
        if (age >= female_lifespan or energy <= 0) { do die; }
    }

    aspect default {
        draw triangle(2) color: full_of_blood ? #darkred : #red; 
    }
}

// --- ยุงตัวผู้: บินหาดอกไม้อย่างเดียว ---
species male_mosquito skills: [moving] {
    int age <- 0;
    float energy <- 1.0;
    
    reflex seek_nectar {
        if (energy < 0.6) { // ตัวผู้เน้นกินน้ำหวานบ่อยกว่า
            flower target <- (flower closest_to self);
            if (target != nil) {
                do goto target: target.location speed: 1.0;
                if (self distance_to target < 1.0) { energy <- 1.0; }
            }
        } else {
            do wander speed: 1.0;
        }
    }

    reflex aging {
        age <- age + 1;
        energy <- energy - 0.08;
        if (age >= male_lifespan or energy <= 0) { do die; }
    }

    aspect default {
        draw triangle(1.2) color: #green;
    }
}











//species female_mosquito skills: [moving] {
//    int age <- 0;
//    float energy <- 1.0; // เพิ่มระดับพลังงาน
//    int eggs_set_count <- 4; // วางไข่ได้ 4 ครั้ง 
//    bool full_of_blood <- false;
//    int digestion_timer <- 3; // เวลาพักเพื่อพัฒนาไข่ 2-3 วัน [cite: 54]
//    
//    reflex fly { do wander speed: 1.5; }
//    
//    
//    // 1. บินไปหาดอกไม้เมื่อพลังงานต่ำ (กินน้ำหวาน)
//    reflex feeding_nectar when: energy < 0.5 {
//        flower target <- (flower closest_to self);
//        if (target != nil) {
//            do goto target: target speed: 1.5;
//            if (self distance_to target < 1.0) {
//                energy <- 1.0; // พลังงานเต็ม
//            }
//        }
//    }
//
//    // 2. กินเลือด (เฉพาะตอนที่พลังงานพอมี และท้องว่าง)
//    reflex seek_blood when: !full_of_blood and energy >= 0.5 {
//        person target <- (person closest_to self);
//        if (target != nil and self distance_to target < 2) {
//            full_of_blood <- true;
//            energy <- energy - 0.2; // การกัดคนใช้พลังงาน
//        }
//    }
//    
//    
////    reflex seek_blood when: !full_of_blood and eggs_set_count < 4 {
////        person target <- (person closest_to self);
////        if (target != nil and self distance_to target < 2) {
////            full_of_blood <- true; // กินเลือดเพื่อสร้างไข่ [cite: 47]
////            digestion_timer <- 0;
////        }
////    }
//    
//    reflex develop_eggs when: full_of_blood {
//        digestion_timer <- digestion_timer + 1;
//        if (digestion_timer >= 3) { // พัก 2-3 วันให้ไข่สมบูรณ์ 
//            // เมื่อไข่พร้อม จะไปหาที่วางไข่ 
//            Puddle_in_the_bucket home <- (Puddle_in_the_bucket closest_to self);
//            if (home != nil and self distance_to home < 2) {
//                // วางไข่ 60-100 ฟองต่อครั้ง [cite: 2]
//                create egg number: 10 { location <- home.location; } 
//                full_of_blood <- false;
//                eggs_set_count <- eggs_set_count + 1;
//            } else {
//                do goto target: home speed: 1.5;
//            }
//        }
//    }
//
//
//reflex aging {
//        age <- age + 1;
//        energy <- energy - 0.05; // พลังงานลดลงเรื่อยๆ ตามเวลา
//        if (age >= female_lifespan or energy <= 0) { do die; }
//        }
//
//
////    reflex aging {
////        age <- age + 1;
////        if (age >= female_lifespan) { do die; }
////    }
//    
//    aspect default {
//        draw triangle(2) color: full_of_blood ? #darkred : #red; 
//    }
//}





//species male_mosquito skills: [moving] {
//    int age <- 0;
//    float energy <- 1.0; // พลังงานเริ่มต้น
//    
//    reflex fly {
//        // ถ้าพลังงานน้อย ให้เลิกบินมั่วแล้วมุ่งหน้าไปหาดอกไม้
//        if (energy < 0.5) {
//            flower target <- (flower closest_to self);
//            if (target != nil) {
//                do goto target: target.location speed: 1.0;
//                if (self distance_to target < 1.0) {
//                    energy <- 1.0; // เติมพลังงานเมื่อถึงดอกไม้
//                }
//            }
//        } else {
//            do wander speed: 1.0;
//        }
//    }
//
//    reflex aging {
//        age <- age + 1;
//        energy <- energy - 0.1; // พลังงานลดลงทุกวัน
//        if (age >= male_lifespan or energy <= 0) { do die; }
//    }
//    
//    aspect default { draw triangle(1.2) color: #green; }
//}


//species male_mosquito skills: [moving] {
//    int age <- 0;
//  //  float energy <- 1.0; // พลังงานเริ่มต้น
//    reflex fly { do wander speed: 1.0; }
//    reflex aging {
//        age <- age + 1;
//        if (age >= male_lifespan) { do die; }
//    }
//    aspect default { draw triangle(1.2) color: #green; }
//}






species person {
    aspect default { draw circle(2.5) color: #orange; }
}

species flower {
    aspect default { draw square(1.5) color: #pink; }
}

experiment main type: gui {
    output {
        display main_display {
            species Puddle_in_the_bucket;
            species flower;
            species person;
            species egg;
            species larva;
            species male_mosquito;
            species female_mosquito;
        }
    }
}