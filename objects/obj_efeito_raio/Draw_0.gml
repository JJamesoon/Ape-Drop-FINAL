//O RAIO: PRIMEIRO UM BRILHO AQUA MAIS LARGO, DEPOIS O RAIO BRANCO POR CIMA
gpu_set_fog(true, #31FCFF, 0, 1);
draw_sprite_ext(spr_raio, frame, x, y, lado * 1.6, esc_y, 0, c_white, alpha * .6);
gpu_set_fog(false, c_white, 0, 1);
draw_sprite_ext(spr_raio, frame, x, y, lado, esc_y, 0, c_white, alpha);

//ANIMA OS 4 FRAMES E DEPOIS VAI SUMINDO
var _n = sprite_get_number(spr_raio);
if(frame < _n - 1) frame = min(frame + .35, _n - 1);
else alpha -= .06;

flash = max(0, flash - .05);
if(alpha <= 0 and flash <= 0) instance_destroy();
