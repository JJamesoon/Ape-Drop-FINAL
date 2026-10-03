//GIROU O CELULAR OU MUDOU O TAMANHO DA JANELA: REFAZ O LAYOUT
if(window_get_width() != global.mob.ww or window_get_height() != global.mob.wh) mobile_layout();
mobile_debug_toques();
