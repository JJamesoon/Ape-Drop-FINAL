//GAMEFEEL==================================
//	ONDA DE CHOQUE: ANEL QUE DISTORCE A TELA (SHADER SH_ONDA_CHOQUE, DESENHADO NO POST DRAW DO OBJ_GAME_CONTROL)
//	HITSTOP: O JOGO CONGELA ALGUNS FRAMES NOS IMPACTOS FORTES
//	POEIRA: FUMACINHA NO PE DO PLAYER (PULO E ATERRISSAGEM)
//USAR POUCO: SO NOS MOMENTOS IMPORTANTES

#macro ONDA_CHOQUE_LARGURA	10	//LARGURA DO ANEL (PX DA ROOM)
#macro CALOR_FORCA			1.2	//CALOR DO LASER: QUANTO A TELA ONDULA (PX DA ROOM, BEM LEVE)
#macro CALOR_PASSADA		16	//FRAMES DA FAIXA DE CALOR IR DO TOPO AO CHAO DO LASER
#macro CALOR_FAIXA			14	//ALTURA DA FAIXA (PX DA ROOM)

//CALOR DO LASER: RETANGULO QUE ONDULA A TELA (_X1/_X2 = LADOS, DO TOPO DA TELA AO CHAO DA ARENA) POR _DUR FRAMES. NO MAXIMO 3
function calor_laser(_x1, _x2, _dur)
{
	if(array_length(global.calor) >= 3) array_delete(global.calor, 0, 1);
	array_push(global.calor, { x1 : _x1, x2 : _x2, t : 0, dur : _dur });
}

//_RAIO = ATE ONDE O ANEL VAI, _FORCA = QUANTO DISTORCE (PX), _DUR = FRAMES
function onda_choque(_x, _y, _raio = 60, _forca = 5, _dur = 28)
{
	//NO MAXIMO 4 ONDAS (O SHADER SO AGUENTA 4): TIRA A MAIS VELHA
	if(array_length(global.ondas_choque) >= 4) array_delete(global.ondas_choque, 0, 1);
	array_push(global.ondas_choque, { x : _x, y : _y, raio : _raio, forca : _forca, dur : _dur, t : 0 });
}

//CONGELA O JOGO POR _FRAMES (SE JA TIVER CONGELADO, FICA O MAIOR)
function hitstop(_frames)
{
	global.congelar = max(global.congelar, _frames);
}

//SOLTA _QTD FUMACINHAS QUE SAEM PROS LADOS E SOMEM
function poeira(_x, _y, _qtd = 4)
{
	repeat(_qtd)
	{
		var _p = instance_create_depth(_x + random_range(-5, 5), _y - 1, -90, obj_efeito_pontos);
		_p.modo = "poeira";
		_p.dir_voo = choose(random_range(150, 180), random_range(0, 30));
		_p.vel_voo = random_range(.4, 1.2);
		_p.velv = -random_range(.1, .5);
		_p.esc = random_range(2, 3.5);
		_p.timer = irandom_range(16, 24);
	}
}

//==================== FUNDO DO JOGO (IGUAL AO PROJETO ANTIGO) ====================
//NA LAYER "BACKGROUND" DA ROOM: A PAREDE DE AZULEJOS COM OS DESENHOS (SPR_BG_NOVO) ESCURECIDA. EM CIMA DELA UMA LAYER NOVA COM O
//CHIADO DE TV (SPR_EFEITO_XIADO) PINTADO NA COR DO LEVEL (1 LARANJA, 2 VERDE, 3 VERMELHO), QUE FICA MAIS FORTE COM O RAIO.
//A VINHETA (SPR_LUNETA) E DESENHADA NA GUI (DRAW_64 DO OBJ_GAME_CONTROL)
#macro FUNDO_ESCURO		make_color_rgb(150, 150, 165)	//O QUANTO A PAREDE DE AZULEJOS FICA ESCURA (PROS BLOCOS APARECEREM)
#macro FUNDO_XIADO		.15								//FORÇA DO CHIADO (COM O RAIO LIGADO VAI PRA .45)
#macro FUNDO_LUNETA		.58								//FORÇA DA VINHETA NAS BORDAS
#macro FUNDO_ARENA		.6								//O PRETO DENTRO DA ARENA (O PROJETO ANTIGO USAVA ~.52)

//CHAMADO NO CREATE DO OBJ_GAME_CONTROL (ARCADE E COOP)
function fundo_iniciar()
{
	fundo_xiado = -1;
	fundo_hue = 40;
	fundo_xiado_a = FUNDO_XIADO;
	var _lay = layer_get_id("Background");
	if(_lay == -1) exit;
	var _bg = layer_background_get_id(_lay);
	layer_background_sprite(_bg, spr_bg_novo);
	layer_background_index(_bg, 0);
	layer_background_speed(_bg, 0);
	layer_background_htiled(_bg, true);
	layer_background_vtiled(_bg, true);
	layer_background_stretch(_bg, false);
	layer_background_blend(_bg, FUNDO_ESCURO);
	layer_background_alpha(_bg, 1);
	var _lx = layer_create(layer_get_depth(_lay) - 10, "Fundo_xiado");
	fundo_xiado = layer_background_create(_lx, spr_efeito_xiado);
	layer_background_htiled(fundo_xiado, true);
	layer_background_vtiled(fundo_xiado, true);
	layer_background_speed(fundo_xiado, 0);
	layer_background_alpha(fundo_xiado, fundo_xiado_a);
}

//CHAMADO TODO FRAME NO OBJ_GAME_CONTROL: ANIMA O CHIADO E VAI MUDANDO A COR DELE PRA COR DO LEVEL
function fundo_atualizar()
{
	if(fundo_xiado == -1) exit;
	var _hues = [40, 120, 0];	//(HSV DO GAMEMAKER, 0 A 255) LEVEL 1, 2 E 3 (DEPOIS REPETE)
	fundo_hue = lerp(fundo_hue, _hues[(max(1, global.level) - 1) mod 3], .05);
	var _t = current_time * .002;
	var _cor = make_color_hsv(fundo_hue + sin(_t) * 3, sin(_t * .25) * 50 + 200, sin(_t * .5) * 50 + 200);
	layer_background_blend(fundo_xiado, _cor);
	layer_background_index(fundo_xiado, (current_time div 100) mod sprite_get_number(spr_efeito_xiado));
	fundo_xiado_a = lerp(fundo_xiado_a, global.raio > 0 ? .45 : FUNDO_XIADO, .1);
	layer_background_alpha(fundo_xiado, fundo_xiado_a);
}