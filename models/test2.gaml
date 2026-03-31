model KeyboardMovement

global {
    geometry shape <- square(100);
    string last_key_pressed <- "None";

    init {
        create player number: 1 {
            location <- {50, 50};
        }
    }
}

species player {
    aspect base {
        draw triangle(6) color: #blue rotate: 90;
    }
}

experiment KeyboardTest type: gui {
    
    // ACTIONS MUST BE HERE for the experiment to "see" them from the display
    action press_w { ask first(player) { location <- location + {0, -5}; } last_key_pressed <- "W"; }
    action press_s { ask first(player) { location <- location + {0, 5}; } last_key_pressed <- "S"; }
    action press_a { ask first(player) { location <- location + {-5, 0}; } last_key_pressed <- "A"; }
    action press_d { ask first(player) { location <- location + {5, 0}; } last_key_pressed <- "D"; }

    output {
        display MainCanvas {
            species player aspect: base;
            
            // Now these actions are in the correct scope
            event "w" action: press_w;
            event "s" action: press_s;
            event "a" action: press_a;
            event "d" action: press_d;
            
            graphics "UI" {
                draw "Last Key: " + last_key_pressed at: {2, 5} color: #black font: font("Arial", 14);
                draw "Click here, then use WASD" at: {2, 12} color: #gray font: font("Arial", 10);
            }
        }
    }
}