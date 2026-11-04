//SKINS DOS PERSONAGENS==================================
//O CODIGO DO PLAYER SEMPRE USA AS SPRITES DO MACACO (SPR_PLAYER_*).
//CADA SKIN SO DIZ QUAL SPRITE DELA SUBSTITUI CADA SPRITE DO MACACO.
//SE A SKIN NAO TIVER UMA ANIMAÇAO, O MACACO E USADO NO LUGAR.
//PRA ADICIONAR UM PERSONAGEM: COLOCA NO ENUM E NO ARRAY GLOBAL.SKINS (NA MESMA ORDEM)

enum personagem
{
	macaco,
	tartaruga,
	falcao,
	dino,
	total
}

//_PRECO = MOEDAS PRA LIBERAR NA TELA DE SELEÇAO (0 = JA VEM LIBERADO)
//_PERFIL = RETRATO DO PERSONAGEM NO HUD (SPR_*_PERFIL, UM FRAME POR EXPRESSAO)
function skin_criar(_nome, _trocas, _preco = 0, _perfil = spr_player_perfil_1)
{
	//TRANSFORMA A LISTA [SPRITE DO MACACO, SPRITE DA SKIN] NUM STRUCT PELO NOME DA SPRITE DO MACACO
	var _sprites = {};
	for(var i = 0; i < array_length(_trocas); i++)
	{
		_sprites[$ sprite_get_name(_trocas[i][0])] = _trocas[i][1];
	}
	return { nome : _nome, sprites : _sprites, preco : _preco, perfil : _perfil };
}

//MUDA A EXPRESSAO DO RETRATO NO HUD POR UM TEMPO (FRAMES: 1 GRITANDO, 3 MACHUCADO, 4 PODER...)
function emocao_mostrar(_frame, _tempo = room_speed)
{
	global.emocao = _frame;
	global.emocao_timer = _tempo;
}

//RETORNA A SPRITE DA SKIN QUE SUBSTITUI ESSA SPRITE DO MACACO
function skin_sprite(_skin, _spr)
{
	if(_skin < 0 or _skin >= array_length(global.skins)) return _spr;

	var _sprites = global.skins[_skin].sprites;
	var _nome = sprite_get_name(_spr);

	if(variable_struct_exists(_sprites, _nome)) return _sprites[$ _nome];
	return _spr;
}

//LISTA DE TODAS AS SKINS (MESMA ORDEM DO ENUM PERSONAGEM)
global.skins = [];

//MACACO (SPRITES ORIGINAIS, NAO TROCA NADA)
global.skins[personagem.macaco] = skin_criar("Macaco", [], 0, spr_player_perfil_1);

//TARTARUGA
//CADA LINHA: [SPRITE DO MACACO, SPRITE DA SKIN QUE ENTRA NO LUGAR]. CUSTA 50 MOEDAS
global.skins[personagem.tartaruga] = skin_criar("Tartaruga", [
	[spr_player_idle,			spr_turtle_1_idle],
	[red_idle2,					spr_turtle_1_idle],
	[spr_player_idle_virando,	spr_turtle_1_idle],
	[spr_player_stop_run,		spr_turtle_1_idle],
	[spr_player_push,			spr_turtle_1_idle],
	[spr_player_run,			spr_turtle_1_run],
	[red_corrida2,				spr_turtle_1_run],
	[spr_player_dash_run,		spr_turtle_1_run],
	[spr_player_push_run,		spr_turtle_1_run],
	[spr_player_jump,			spr_turtle_1_jump],
	[spr_player_fall,			spr_turtle_1_jump],
	[spr_player_jump_giro,		spr_turtle_1_girando],
	[spr_player_giro,			spr_turtle_1_girando],
	[spr_player_giro_1,			spr_turtle_1_girando],
	[spr_player_wall,			spr_turtle_1_wall],
	[spr_player_climb,			spr_turtle_1_wall],
	[spr_player_soco,			spr_turtle_1_soco],
	[spr_player_soco_fail,		spr_turtle_1_soco],
	[spr_player_empurra,		spr_turtle_1_soco],
	[spr_player_super_soco,		spr_turtle_1_super_soco],
], 50, spr_turtle_perfil_1);

//FALCAO
//CUSTA 100 MOEDAS
global.skins[personagem.falcao] = skin_criar("Falcao", [
	[spr_player_idle,			spr_falcao_1_idle],
	[red_idle2,					spr_falcao_1_idle],
	[spr_player_idle_virando,	spr_falcao_1_idle],
	[spr_player_stop_run,		spr_falcao_1_idle],
	[spr_player_push,			spr_falcao_1_idle],
	[spr_player_run,			spr_falcao_1_run],
	[red_corrida2,				spr_falcao_1_run],
	[spr_player_dash_run,		spr_falcao_1_run],
	[spr_player_push_run,		spr_falcao_1_run],
	[spr_player_jump,			spr_falcao_1_jump],
	[spr_player_fall,			spr_falcao_1_jump],
	[spr_player_jump_giro,		spr_falcao_1_girando],
	[spr_player_giro,			spr_falcao_1_girando],
	[spr_player_giro_1,			spr_falcao_1_girando],
	[spr_player_wall,			spr_falcao_1_wall],
	[spr_player_climb,			spr_falcao_1_wall],
	[spr_player_soco,			spr_falcao_1_soco],
	[spr_player_soco_fail,		spr_falcao_1_soco],
	[spr_player_empurra,		spr_falcao_1_soco],
	[spr_player_super_soco,		spr_falcao_1_super_soco],
], 100, spr_falcao_perfil);

//DINO
//CUSTA 200 MOEDAS
global.skins[personagem.dino] = skin_criar("Dino", [
	[spr_player_idle,			spr_dino_1_idle],
	[red_idle2,					spr_dino_1_idle],
	[spr_player_idle_virando,	spr_dino_1_idle],
	[spr_player_stop_run,		spr_dino_1_idle],
	[spr_player_push,			spr_dino_1_idle],
	[spr_player_run,			spr_dino_1_run],
	[red_corrida2,				spr_dino_1_run],
	[spr_player_dash_run,		spr_dino_1_run],
	[spr_player_push_run,		spr_dino_1_run],
	[spr_player_jump,			spr_dino_1_jump],
	[spr_player_fall,			spr_dino_1_jump],
	[spr_player_jump_giro,		spr_dino_1_giro],
	[spr_player_giro,			spr_dino_1_giro],
	[spr_player_giro_1,			spr_dino_1_giro],
	[spr_player_wall,			spr_dino_1_wall],
	[spr_player_climb,			spr_dino_1_wall],
	[spr_player_soco,			spr_dino_1_soco],
	[spr_player_soco_fail,		spr_dino_1_soco],
	[spr_player_empurra,		spr_dino_1_soco],
	[spr_player_super_soco,		spr_dino_1_super_soco],
], 200, spr_dino_perfil);

//PERSONAGEM ESCOLHIDO POR CADA JOGADOR (O SAVE PODE TROCAR ISSO)
global.skin_player_1 = personagem.macaco;
global.skin_player_2 = personagem.macaco;
