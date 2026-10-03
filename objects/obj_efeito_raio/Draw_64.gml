//FLASH AQUA NA TELA TODA (UM BRANCO NO PRIMEIRO INSTANTE, DEPOIS AQUA)
if(flash > 0)
{
	var _tl = gui_tela();
	draw_set_alpha(flash);
	draw_set_color(flash > .6 ? c_white : #31FCFF);
	draw_rectangle(_tl[0], _tl[1], _tl[2], _tl[3], false);
	draw_set_alpha(1);
	draw_set_color(c_white);
}
