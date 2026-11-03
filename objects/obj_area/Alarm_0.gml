//ZORG ABRE A PARTIDA (SCR_PODERES): A PRIMEIRA PEÇA ESPERA ELE FALAR E SUMIR
if(zorg_segurando()) { alarm[0] = 5; exit; }


//CRIA A PROXIMA PEÇA E MARCA QUANDO VEM A SEGUINTE
criar_bloco();
alarm[0] = peca_tempo_criar(); //FICA MAIS RAPIDO A CADA LEVEL, A CADA ANDAR E COM O TEMPO
if(global.dupla_timer > 0 and instance_exists(obj_cria_peca)) { dupla_espera = DUPLA_ESPACO; dupla_tentativas = 0; } //PEÇAS DUPLAS: OUTRA LOGO ATRAS
if(global.debug_bloco != "" and !instance_exists(obj_cria_peca)) alarm[0] = 10; //BLOCO DO MENU DE DEBUG ESPERANDO O TOPO LIBERAR