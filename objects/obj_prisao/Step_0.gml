//ANTIGO (NINGUEM CRIA MAIS): ANIMAÇAO DE PRISAO QUE PAUSAVA O JOGO E IA ATE O PLAYER
global.game_pause = true;
ultima_spr();
//DEPOIS DO FRAME 6 A PRISAO VOA ATE O PLAYER
if(image_index > 6)
{
	x = lerp(x, obj_player.x, .2);
	y = lerp(y, obj_player.y - 15, .2);
}