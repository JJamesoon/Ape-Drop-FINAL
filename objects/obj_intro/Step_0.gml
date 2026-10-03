teste_menu(); //TESTE AUTOMATICO (SO COM TESTE_MENU LIGADO)

//PULAR A INTRO
if(keyboard_check_pressed(vk_space) or keyboard_check_pressed(vk_enter) or mouse_check_button_pressed(mb_left))
{
	ir_menu();
	exit;
}

//PASSA DE LOGO EM LOGO. ACABOU A ULTIMA: MENU
timer++;
if(timer >= fases[fase])
{
	timer = 0;
	fase++;
	if(fase >= array_length(fases))
	{
		fase = array_length(fases) - 1;
		timer = fases[fase];
		ir_menu();
	}
	else som_tocar(snd_intro_vento, .05);
}
