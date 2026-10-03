//TESTE AUTOMATICO DA INTRO E DO MENU (SO RODA COM TESTE_MENU LIGADO): APERTA AS TECLAS SOZINHO E TIRA PRINTS
//(OS PRINTS VAO PRA %LOCALAPPDATA%\APEDROP_FINAL). CHAMADO NO STEP DO OBJ_INTRO E DO OBJ_MENU_PRINCIPAL
#macro TESTE_MENU false

function teste_menu()
{
	if(!TESTE_MENU) exit;
	if(!variable_global_exists("tm_t")) { global.tm_t = 0; global.tm_room = room; global.tm_rt = 0; global.tm_solta = -1; }
	if(room != global.tm_room) { global.tm_room = room; global.tm_rt = 0; }
	global.tm_t++;
	global.tm_rt++;
	if(global.tm_solta != -1) { keyboard_key_release(global.tm_solta); global.tm_solta = -1; }
	var _t = global.tm_rt;
	//INTRO: UM PRINT DE CADA LOGO
	if(room == rm_intro)
	{
		if(_t == 70) screen_save("tm_1_logo_jogo.png");
		if(_t == 210) screen_save("tm_2_gamemaker.png");
		if(_t == 370) screen_save("tm_3_canary.png");
		exit;
	}
	//MENU: [FRAME, TECLA OU -1, NOME DO PRINT OU ""]
	var _passos = [
		[60, -1, "tm_04_titulo"], [70, vk_enter, ""], [110, -1, "tm_05_menu"],
		[120, vk_down, ""], [140, vk_enter, ""], [170, -1, "tm_06_versus"], [180, vk_down, ""], [200, -1, "tm_07_coop"], [210, vk_escape, ""],
		[230, vk_down, ""], [250, vk_enter, ""], [270, -1, "tm_08_tutorial"],
		[290, vk_down, ""], [310, vk_enter, ""], [330, -1, "tm_09_ranks"], [340, vk_escape, ""],
		[350, vk_left, ""], [370, -1, "tm_10_sel_config"], [380, vk_enter, ""], [410, -1, "tm_11_config"],
		[420, vk_enter, ""], [450, -1, "tm_12_audio"], [460, vk_escape, ""],
		[470, vk_down, ""], [480, vk_enter, ""], [510, -1, "tm_13_controles"], [520, vk_escape, ""],
		[530, vk_down, ""], [540, vk_enter, ""], [570, -1, "tm_14_jogo"], [580, vk_escape, ""],
		[590, vk_escape, ""], [610, vk_right, ""], [615, vk_right, ""], [635, -1, "tm_15_sel_creditos"], [640, vk_enter, ""], [800, -1, "tm_16_creditos"],
		[810, vk_escape, ""], [840, -1, "tm_17_volta"], [850, vk_escape, ""], [890, -1, "tm_18_titulo"],
	];
	for(var i = 0; i < array_length(_passos); i++)
	{
		var _p = _passos[i];
		if(_t != _p[0]) continue;
		if(_p[1] != -1) { keyboard_key_press(_p[1]); global.tm_solta = _p[1]; }
		if(_p[2] != "") screen_save(_p[2] + ".png");
	}
	if(_t == 900) game_end();
}
