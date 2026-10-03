//BLOCO EM CHAMAS (O BLOCO QUE O BURACO ENGOLIU). FASES:
//	"engolir": GIRA E ENCOLHE PRA DENTRO DO REDEMOINHO DO BURACO, COM FAISCAS ROXAS SENDO PUXADAS
//	"portal":  UM PORTAL ROXO ABRE NO TOPO DA ARENA, NA COLUNA DO PLAYER, E O BLOCO SAI DE DENTRO DELE PEGANDO FOGO.
//			   FICA UM POUCO PARADO MOSTRANDO A COLUNA ONDE VAI CAIR (AVISO)
//	caindo:    CAI DIRETO NA VELOCIDADE DA PEÇA RAIVOSA, QUEBRANDO TODOS OS BLOCOS DO CAMINHO. DA DANO NO PLAYER
//			   E SOME QUANDO CHEGA NO CHAO (OBJ_BLOCK)
//SPR/IMG = A CARA DO BLOCO ENGOLIDO, FASE E Y_BURACO VEM NO STRUCT DO INSTANCE_CREATE
if(!variable_instance_exists(id, "spr")) spr = spr_peca;
if(!variable_instance_exists(id, "img")) img = 0;
if(!variable_instance_exists(id, "fase")) fase = "portal";
if(!variable_instance_exists(id, "y_buraco")) y_buraco = y;
sprite_index = spr_peca;	//A COLISAO E A MESMA DOS BLOCOS
mask_index = spr_peca;
image_speed = 0;
timer_fase = 0;			//FRAMES NA FASE ATUAL
y_inicio = y;			//DE ONDE O BLOCO COMEÇA A SER PUXADO PRO BURACO
aviso	= FOGO_AVISO;	//FRAMES PARADO NO TOPO MOSTRANDO A COLUNA ONDE VAI CAIR
chamas	= [];			//FAISCAS SUBINDO: [X, Y, VELH, VELV, VIDA]
esc		= fase == "portal" ? 0 : 1;	//SAINDO DO PORTAL ELE CRESCE DO ZERO
