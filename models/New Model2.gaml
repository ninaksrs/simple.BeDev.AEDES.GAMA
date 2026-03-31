//model Dengue_Mosquito_Simple
//
//global {
//  
//}
//
//
//species Puddle_in_the_bucket{
//	
//}
//
//species egg {
//    
//}
//
//species larva {
//   
//}
//
//species female_mosquito {
//   
//}
//
//species male_mosquito {
//   
//}
//
//species person {
//   
//}
//
//species flower{
//	
//}
//
//experiment main type: gui {
//    output {
//    	monitor "A monitor simulation" ;
//        display main_display {
//       
//        }
//    }
//}










model Dengue_Mosquito_Simple

global {
    // Environment settings
    int world_size <- 100;
    geometry shape <- square(world_size);
    
    // Lifespan and timing parameters (in days) [cite: 5]
    int male_lifespan <- 7 + rnd(3); // 7-10 days 
    int female_lifespan <- 30; // ~30 days 
    
    init {
        create Puddle_in_the_bucket number: 50;
        create flower number: 100;
        create person number: 100;
        // Start with some initial mosquitoes
        create male_mosquito number: 1000;
        create female_mosquito number: 1000;
    }
}

/* --- Life Cycle Stages --- */

species egg {
    int age <- 0;
    bool in_water <- true; // Needs water to hatch [cite: 70]
    
    reflex develop {
        age <- age + 1;
        // Hatch after 2-3 days if in water [cite: 6]
        if (age >= 2 and in_water) {
            if (flip(0.9)) { // 80-95% hatching rate 
                create larva { location <- myself.location; }
            }
            do die;
        }
    }
    
    aspect default { draw circle(0.2) color: #black; }
}

species larva {
    int age <- 0;
    reflex grow {
        age <- age + 1;
        // Larva stage lasts 5-7 days [cite: 8]
        if (age >= 5) {
            create pupa { location <- myself.location; }
            do die;
        }
    }
    aspect default { draw circle(0.5) color: #blue; }
}

species pupa {
    int age <- 0;
    reflex transform {
        age <- age + 1;
        // Pupa stage lasts 1-2 days [cite: 9]
        if (age >= 1) {
            // 50/50 chance of being male or female 
            if (flip(0.5)) { create male_mosquito { location <- myself.location; } }
            else { create female_mosquito { location <- myself.location; } }
            do die;
        }
    }
    aspect default { draw circle(0.6) color: #gray; }
}

/* --- Adults --- */

species male_mosquito {
    int age <- 0;
    
    reflex fly { location <- location + {rnd(-2,2), rnd(-2,2)}; }
    
    reflex life_expectancy {
        age <- age + 1;
        if (age > 10) { do die; } // Dies after 7-10 days [cite: 33]
    }
    
    aspect default { draw triangle(1.0) color: #green; }
}

species female_mosquito {
    int age <- 0;
    bool has_mated <- false;
    int eggs_to_lay <- 0;
    bool has_blood_meal <- false;
    
    reflex hunt_or_mate {
        if (!has_mated) {
            // Logic to find male_mosquito [cite: 44]
        } else if (!has_blood_meal) {
            // Logic to find person for blood (protein for eggs) [cite: 47, 48]
        } else {
            // Logic to find Puddle_in_the_bucket to lay eggs 
        }
    }

    reflex life_expectancy {
        age <- age + 1;
        if (age > 30) { do die; } // Dies around 30 days 
    }

    aspect default { draw triangle(1.2) color: has_blood_meal ? #red : #pink; }
}

/* --- Environment Objects --- */

species Puddle_in_the_bucket {
    aspect default { draw square(4) color: #lightblue; }
}

species flower {
    aspect default { draw flower(1.5) color: #yellow; }
}

species person {
    aspect default { draw circle(2) color: #orange; }
}

experiment main type: gui {
    output {
        display main_display background: #black {
            species Puddle_in_the_bucket;
            species flower;
            species person;
            species egg;
            species larva;
            species pupa;
            species male_mosquito;
            species female_mosquito;
        }
        monitor "Total Female Mosquitoes" value: length(female_mosquito);
    }
}