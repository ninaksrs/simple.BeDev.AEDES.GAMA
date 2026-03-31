model first_person

global {
    int environment_size <- 100;
    geometry shape <- cube(environment_size);
    
    init {
        create first_person number: 1 {
            location <- {environment_size/2, environment_size/2, 2.0};
        }
        write "--- Simulation Started: Use WASD to move ---";
    }
}

species first_person {
    float step_size <- 1.0;

    action move_up { 
        location <- location + {0, -step_size, 0}; 
        write "Pressed: W (Up) | Current Location: " + location;
    }
    action move_down { 
        location <- location + {0, step_size, 0}; 
        write "Pressed: S (Down) | Current Location: " + location;
    }
    action move_left { 
        location <- location + {-step_size, 0, 0}; 
        write "Pressed: A (Left) | Current Location: " + location;
    }
    action move_right { 
        location <- location + {step_size, 0, 0}; 
        write "Pressed: D (Right) | Current Location: " + location;
    }

    aspect default {
        draw sphere(2) color: #blue;
    }
}

experiment main type: gui {
    output {
        display map type: opengl {
            graphics "floor" {
                draw square(environment_size) color: #lightgray;
            }
            species first_person aspect: default;
            
            // ปุ่มควบคุมพร้อมคำสั่ง log
            event "w" { ask first_person { do move_up; } }
            event "s" { ask first_person { do move_down; } }
            event "a" { ask first_person { do move_left; } }
            event "d" { ask first_person { do move_right; } }
        }
    }
}