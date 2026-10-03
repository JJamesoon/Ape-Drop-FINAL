//O QUEBRA-CABEÇA ACABOU: O JOGO VOLTA A ANDAR E LIBERA O SPRITE DO CUBO
global.quebra_parado = false;
if(sprite_exists(cubo_spr)) sprite_delete(cubo_spr);
