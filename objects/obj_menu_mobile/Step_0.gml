//ANIMAÇOES: TEMPO, ESPERA INICIAL E O TITULO DESCENDO
timer += .06;
if(timer_inicio > 0) timer_inicio--;
y_titulo = lerp(y_titulo, room_height * .26, .1);

//NAO ACEITA TOQUE DURANTE A TRANSIÇAO
if(instance_exists(obj_transisao) or timer_inicio > 0) exit;

//TOCOU EM QUALQUER LUGAR (OU ENTER/ESPAÇO NO PC): VAI ESCOLHER O PERSONAGEM
if(device_mouse_check_button_released(0, mb_left) or keyboard_check_pressed(vk_enter) or keyboard_check_pressed(vk_space))
{
	som_tocar(snd_menu_select_01);
	global.coop = false;
	scr_trans(rm_selecao);
}
//BOTAO VOLTAR DO ANDROID (CHEGA COMO BACKSPACE): SALVA E FECHA O JOGO
else if(keyboard_check_pressed(vk_backspace))
{
	jogo_salvar();
	game_end();
}
