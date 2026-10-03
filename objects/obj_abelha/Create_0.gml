//ABELHINHA DA COLMEIA: VOA ATE O BLOCO PARADO MAIS PERTO E SE DESTROI LEVANDO ELE JUNTO.
//NAO DA DANO NO PLAYER E O PLAYER NAO CONSEGUE ABATER ELA (ELA NAO TEM COLISAO COM NADA).
//DONO = A COLMEIA QUE SOLTOU (VEM NO STRUCT DO INSTANCE_CREATE)
if(!variable_instance_exists(id, "dono")) dono = noone;
alvo	= noone;		//BLOCO QUE ELA VAI DESTRUIR
timer	= irandom(60);	//TEMPO DE VOO (PRO BALANÇO)
sem_alvo = 0;			//FRAMES SEM ACHAR BLOCO NENHUM (DEPOIS DE UM TEMPO ELA SOME)
asa		= 0;			//ANIMAÇAO DAS ASAS
lado	= 1;			//PRA ONDE ELA OLHA (A SPRITE OLHA PRA DIREITA)
vel_x	= random_range(-.5, .5);
vel_y	= -1.2;			//SAI DA COLMEIA SUBINDO
image_speed = 0;

//PROCURA O BLOCO PARADO MAIS PERTO QUE NENHUMA OUTRA ABELHA ESCOLHEU (NAO PEGA COLMEIA, BLOCO CAINDO NEM O FUJAO ANDANDO)
procurar_alvo = function()
{
	var _eu = id;
	var _melhor = noone, _dist = infinity;
	with(obj_peca)
	{
		if(!estou_parado or andar or destruido_por != noone or sou_colmeia or fujao_controle or gel_quicando) continue;
		var _b = id, _ocupado = false;
		with(obj_abelha) if(id != _eu and alvo == _b) _ocupado = true;
		if(_ocupado) continue;
		var _d = point_distance(x, y, _eu.x, _eu.y);
		if(_d < _dist)
		{
			_dist = _d;
			_melhor = id;
		}
	}
	return _melhor;
}
