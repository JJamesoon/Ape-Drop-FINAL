//ANIMAÇAO DA MOEDA GIRANDO
frame += .3;
esc = lerp(esc, 1, .12);

//PEGOU: VAI RETO ATE A CAIXINHA DO HUD, ACELERANDO (A MOEDA JA FOI SOMADA, AQUI E SO O EFEITO).
//(ANTES ELA IA VIRANDO AOS POUCOS E FICAVA DANDO VOLTA EM TORNO DA CAIXINHA SEM CHEGAR)
if(pegou)
{
	vel = min(vel + .4, 9);
	var _dist = point_distance(x, y, prox_x, prox_y);
	if(_dist <= vel)
	{
		with(obj_borda) moeda_esc = 1.5;
		instance_destroy();
		exit;
	}
	var _dir = point_direction(x, y, prox_x, prox_y);
	x += lengthdir_x(vel, _dir);
	y += lengthdir_y(vel, _dir);
	exit;
}

//PAUSADO: A MOEDA FICA PARADA (NO TEMPO PARADO O PLAYER AINDA PEGA ELA)
if(global.game_pause and !tempo_player_livre()) exit;
var _mov = !global.game_pause;

//ACABOU O TEMPO: SOME
if(_mov)
{
	timer++;
	if(timer >= MOEDA_VIDA) { instance_destroy(); exit; }
}

var _p = player_perto(x, y); //NO COOP, O MAIS PERTO

//IMA: PUXA A MOEDA PRO PLAYER
if(!_mov) { /* TEMPO PARADO: NAO SE MEXE */ }
else if(_p != noone and tem_poder("ima", _p.jogador) and point_distance(x, y, _p.x, _p.y - 10) < IMA_RAIO)
{
	var _dir = point_direction(x, y, _p.x, _p.y - 10);
	x += lengthdir_x(3, _dir);
	y += lengthdir_y(3, _dir);
}
else if(saindo)
{
	//PULINHO SAINDO DO BLOCO: SOBE E FREIA. DEPOIS SORTEIA PRA ONDE VAI (MAIS CHANCE DE IR PRA BAIXO)
	x += velh;
	y += velv;
	velv += .1;
	if(velv >= -.3)
	{
		saindo = false;
		velv = (random(100) < MOEDA_CHANCE_BAIXO ? 1 : -1) * vel_zig;
	}
}
else
{
	//ZIGUE-ZAGUE: ANDA NA DIAGONAL E BATE NAS BORDAS DA ARENA (DO TOPO ATE QUASE O CHAO: O PLAYER EM PE ALCANÇA)
	x += velh;
	y += velv;
	if(instance_exists(obj_area))
	{
		var _a = obj_area;
		if(x < _a.x + 10 or x > _a.x + _a.sprite_width - 10) { velh *= -1; x = clamp(x, _a.x + 10, _a.x + _a.sprite_width - 10); }
		if(y < _a.y + 20 or y > _a.y + _a.sprite_height - 12) { velv *= -1; y = clamp(y, _a.y + 20, _a.y + _a.sprite_height - 12); }
	}
}

//PLAYER VIVO ENCOSTOU: PEGA (CONTA A MOEDA E VOA PRO HUD)
if(timer > MOEDA_PEGAR and _p != noone and point_distance(x, y, _p.x, _p.y - 10) < 16)
{
	pegou = true;
	global.moedas += 1;
	global.moedas_partida += 1;
	som_moeda(); //NOTA QUE SOBE A CADA MOEDA SEGUIDA
	vel = 1;
	if(instance_exists(obj_borda))
	{
		prox_x = obj_borda.x + obj_borda.dx_hud + 187;
		prox_y = obj_borda.y + 188;
	}
}
