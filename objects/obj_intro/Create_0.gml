//INTRO DO JOGO (PRIMEIRA ROOM): LOGO DO APE DROP -> LOGO DO GAMEMAKER -> CANARY TEAM. DEPOIS VAI PRO MENU
//(TELA DE TITULO). ESPAÇO, ENTER OU CLIQUE PULA A INTRO
som_iniciar_controle(); //CARREGA O SAVE (IDIOMA, VOLUME) ANTES DE MOSTRAR OS TEXTOS
if(TESTE_AUTO or TESTE_BLOCOS or TESTE_ARCADE) { global.coop = TESTE_COOP and !TESTE_AUTO; room_goto(global.coop ? rm_coop : rm_arcade); exit; } //TESTE: PULA A INTRO E O MENU (TESTE_COOP: JA NO COOP)

#macro INTRO_FADE	20		//FRAMES APARECENDO E SUMINDO EM CADA LOGO
fases = [room_speed * 2.4, room_speed * 2.2, room_speed * 3];	//DURAÇAO DE CADA LOGO (JOGO, GAMEMAKER, CANARY)
fase = 0;		//LOGO ATUAL
timer = 0;		//FRAMES NA LOGO ATUAL
saindo = false;	//JA PEDIU PRA IR PRO MENU

//VAI PRO MENU (UMA VEZ SO)
ir_menu = function()
{
	if(saindo) exit;
	saindo = true;
	scr_trans(menu_room());
}

som_tocar(snd_intro_vento);
