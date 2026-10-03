//LAYOUT MOBILE (SCR_MOBILE): CAMERA, GUI E BOTOES DE TOQUE. PERSISTENTE (CRIADO PELA PRIMEIRA ROOM)
//DESENHA POR CIMA DE TUDO
depth = -15000;
//TESTE DO CELULAR NO PC: JANELA EM PE
if(MOB_TESTE_PC and os_type == os_windows)
{
	window_set_size(450, 900);
	window_center();
}
mobile_layout();
