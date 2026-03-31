model test

global {
	 int port <- 9876;
    int environment_size <- 100;
    geometry shape <- cube(environment_size);
    
    init {
        create home number: 1 {
           
        }
       
    }
}

species home {
     aspect default {
        // เปลี่ยนจากสี่เหลี่ยมเป็นกล่อง (บ้าน)
        draw box(10, 10, 10) color: #gray border: #black; 
    }
}

experiment main type: gui {
    output {
        display map type: opengl {
            graphics "test" {
                draw square(environment_size) color: #lightgray;
            }
            species home;
            
      
         
        }
    }
}