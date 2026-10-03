//ANTIGO
//TIMER+= .48;

//SEGURA O JOGO UM POUCO E FAZ OS RAIOS DA LINHA VIBRAREM
pausar_seg(5);
modificar_raios(7, minha_linha);

//PRIMEIRO FRAME: PREPARA O TEMPO E O Y DE CADA LINHA
if(array_length(timer_array) == 0) 
{
	for(var i = 0; i < qtd; i ++) 
	{
		array_push(timer_array, 0);
		array_push(y_array, meu_y - CEL * i);
	}
}

//RETANGULO ANTIGO SUMINDO
if(timer > 3) alpha_rec -= .2;

var _area =  minha_area;
var _line =  minha_linha

//VELOCIDADE DA ANIMAÇAO. CADA LINHA SO COMEÇA DEPOIS QUE A DE BAIXO ANDOU UM POUCO
var _mult = .48;
for(var i = 0; i < qtd; i ++) 
{
	if(i == 0) timer_array[i] += _mult;
	else
	{
		if(timer_array[i-1] > 8) timer_array[i] += _mult;
	}
	
	timer_array[i] = clamp(timer_array[i], 0,  sprite_get_number(spr_efeito_line_solo)-1);
	
	//NO FRAME 3 DA ANIMAÇAO QUEBRA OS BLOCOS DA LINHA
	if(timer_array[i] > 3) criar_bloco(y_array[i]);
	
	
	//VERSOES ANTIGAS DO EFEITO (DESLIGADAS)
	//VERSAO INDIVIDUAL
	//IF(TIMER_ARRAY[I] > 0) DRAW_SPRITE_EXT(SPR_EFEITO_LINE, TIMER_ARRAY[I], _AREA.X, Y_ARRAY[I], IMAGE_XSCALE, 1, 0, C_WHITE, 1);
	
	//VERSAO EM AREA
	//VAR _INDEX = ALT == CEL ? SPR_EFEITO_LINE_SOLO : SPR_EFEITO_LINE_COMBO;
	
	//IF(_INDEX == SPR_EFEITO_LINE_COMBO) 
	//{
	//	DRAW_SPRITE(SPR_EFEITO_LINE_TOP, TIMER_ARRAY[I], _AREA.X, Y-10);
	//}
	//IF(TIMER_ARRAY[I] > 0) DRAW_SPRITE_EXT(_INDEX, TIMER_ARRAY[I], _AREA.X, Y-8, IMAGE_XSCALE, ALT/CEL, 0, C_WHITE, 1);
	
	//DESENHA O EFEITO (O BRILHO DE CIMA E A LINHA)
	if(timer_array[i] > 0)
	{
		//DRAW_SPRITE_EXT(SPR_EFEITO_LINE_SOLO, TIMER_ARRAY[I], _AREA.X, Y-8, IMAGE_XSCALE, ALT/CEL + .2, 0, C_WHITE, 1);
		draw_sprite_ext(spr_efeito_line_top, timer_array[i], _area.x, y-8, image_xscale, alt/CEL, 0, c_white, 1);
		draw_sprite_ext(spr_efeito_line_solo, timer_array[i], _area.x, y-11, image_xscale, alt/CEL, 0, c_white, 1);
	}

}
var tam_w = 10; //10 = ARCADE

//EFEITO DE BORDA NAO FICOU COMO IMAGINADO
//IF(LINE) DRAW_SPRITE_EXT(SPR_EFEITO_LINE_2, GET_TIMER()/100000, X, Y, TAM_W, ALT/CEL+.35, 0, C_WHITE, ALPHA_REC);


//DRAW_SPRITE(SPR_EFEITO_LINE, TIMER, OBJ_AREA.X, MEU_Y);

//A ANIMAÇAO ACABOU: PASSA PRA PROXIMA LINHA OU SE DESTROI
if(timer_array[array_length(timer_array)-1] >= sprite_get_number(spr_efeito_line_solo)-1)
{
	if(qtd > 1)
	{
		timer = 0;
		qtd --;
		meu_y -= CEL;
	}else instance_destroy();
	
	//CHEGOU NA META DO ANDAR? (ANDAR 1 = 2 LINHAS, 2 = 6, 3 = 10)
	var _andar_1;
	var _andar_2;
	var _andar_3;
	
		//IF(SOMAR) GLOBAL.LINHAS_COMPLETADAS++;
	
		_andar_1 = global.linhas_completadas >= 2 and global.andar == 1;
		_andar_2 = global.linhas_completadas >= 6 and global.andar == 2;
		_andar_3 = global.linhas_completadas >= 10 and global.andar == 3;
	
	
	if(_andar_1 or _andar_2 or _andar_3) 
	{
		//AQUI DEVEMOS ELEVAR O NIVEL DA REGUA
		//PAUSAR_SEG(40);
		minha_linha.elevar_nivel();
	}
	else if(subir_andar) with(minha_linha) if(alarm[0] == -1) elevar_nivel();
}




//DRAW_SPRITE(SPR_EFEITO_LINE_2, 0, X, Y);



