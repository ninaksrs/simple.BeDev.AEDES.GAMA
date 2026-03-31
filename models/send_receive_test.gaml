/**
* Name: SendAndReceiveMessage
* ตัวอย่างการส่งและรับข้อความระหว่าง GAMA กับ Unity
*/

model SendAndReceiveMessage   // โมเดลหลัก

// 🔗 ตัวเชื่อมระหว่าง GAMA กับ Unity
species unity_linker parent: abstract_unity_linker {

	// กำหนด species ที่ใช้แทน player จาก Unity
	string player_species <- string(unity_player);

	// ไม่ส่งข้อมูล world ไป Unity ทุก step (ช่วยลดโหลด)
	bool do_send_world <- false;
	
	
	// 🔁 ทำงานทุก 100 cycle และต้องมี player อยู่
	reflex send_message when: every(100 #cycle) and not empty(unity_player){
		
		// แสดงข้อความใน console
		write "Send message: "  + cycle;
		
		// 📤 ส่ง message ไปยัง player ทุกคนใน Unity
		// รูปแบบเป็น map: "ชื่อข้อมูล"::ค่า
		do send_message players: unity_player as list mes: ["cycle":: cycle];
	}
	
	// 📥 รับ message จาก Unity
	action receive_message (string id, string mes, int hp, float x, int score) {
		write "Player " + id + " send the message: " + mes + " score: " + score+ " x: " + x;
	}
}


// 🎮 species สำหรับแทน player จาก Unity
species unity_player parent: abstract_unity_player;


// 🧪 experiment ปกติ (ไม่ใช้ Unity)
experiment SimpleMessage type: gui ;


// 🥽 experiment สำหรับ Unity / VR
experiment vr_xp parent:SimpleMessage autorun: false type: unity {

	// เวลาขั้นต่ำต่อ 1 cycle (ความเร็ว simulation)
	float minimum_cycle_duration <- 0.05;

	// ระบุว่าจะใช้ species ไหนเป็นตัว linker
	string unity_linker_species <- string(unity_linker);


	// 👤 เมื่อมี player ใหม่เชื่อมเข้ามา
	action create_player(string id) {
		ask unity_linker {
			do create_player(id);   // สร้าง player ใน GAMA
		}
	}

	// ❌ เมื่อ player ออกจากระบบ
	action remove_player(string id_input) {
		if (not empty(unity_player)) {
			ask first(unity_player where (each.name = id_input)) {
				do die;   // ลบ player ออกจาก simulation
			}
		}
	}
}