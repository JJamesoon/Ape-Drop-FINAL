//EFEITO DO BLOCO RAIO: UM RAIO CAI DO CEU NO LUGAR DO BLOCO (SPR_RAIO, A ORIGEM E A PONTA DE BAIXO)
//E A TELA TODA DA UM FLASH AQUA. CRIADO PELO RAIO_ATIVAR (SCR_PONTOS)
frame = 0;		//FRAME DA ANIMAÇAO DO RAIO
alpha = 1;		//O RAIO SOME DEPOIS DA ANIMAÇAO
flash = .8;		//FLASH DA TELA (VAI SUMINDO)
lado = choose(-1, 1); //O RAIO PODE VIR ESPELHADO
//O RAIO TEM 300PX: ESTICA PRA SAIR DO TOPO DA TELA ATE O BLOCO
esc_y = max(.4, (y + 20) / 298);

//FAISCAS AQUA SAINDO DO BLOCO
repeat(8)
{
	var _e = instance_create_depth(x, y, -1900, obj_efeito_pontos);
	_e.modo = "estilhaco";
	_e.frame = 3; //BLOCO AQUA
	_e.dir_voo = random(360);
	_e.vel_voo = random_range(1.5, 3.5);
	_e.velv = -random_range(1.5, 3.5);
	_e.ang = random(360);
	_e.giro = random_range(-15, 15);
	_e.esc = random_range(.2, .35);
	_e.timer = irandom_range(24, 36);
}
//ANEL BRANCO NO BLOCO
var _anel = instance_create_depth(x, y, -1900, obj_efeito_pontos);
_anel.modo = "anel";
_anel.timer = 14;
_anel.esc_anel = 2; //ANEL MAIOR QUE O DA IRMANDADE
