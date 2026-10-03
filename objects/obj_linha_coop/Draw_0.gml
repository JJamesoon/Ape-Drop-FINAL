//LINHA DOS ANDARES DO COOP: UM RAIO EM ZIGUE-ZAGUE ENTRE AS DUAS CAPSULAS (CODIGO ANTIGO)
//DRAW_SPRITE(SPRITE_INDEX, IMAGE_INDEX, X + GLOBAL.SHAKE_X, Y + GLOBAL.SHAKE_Y)
//DRAW_TEXT(X - 20, Y, Y);


// QUANTAS "PARTES" O RAIO TEM
var qtd_segmentos = 12;
var x2_raio = x + sprite_get_width(spr_area_coop)+8 + 14;

// FORÇA DO ZIG-ZAG (QUANTO MAIOR, MAIS MALUCO O RAIO FICA)
intensidade = lerp(intensidade, 0, .05); 
tam_raio = lerp(tam_raio, 3, .05); 


// DIREÇÃO INICIAL (DO PLAYER ATÉ O MOUSE)
// (NA PRÁTICA NEM PRECISA AQUI, MAS VOCÊ COLOCOU PRA REFERÊNCIA)
var dir = point_direction(x - 30, y, x2_raio, y);

// COMEÇA DO PERSONAGEM
var atual_x = x;
var atual_y = y;
var _cor = c_yellow;

// LOOP: VAI CRIANDO O RAIO PARTE POR PARTE
for (var i = 0; i < qtd_segmentos; i++)
{
    // OLHA PRO ALVO (MOUSE)
    var dir_base = point_direction(atual_x, atual_y, x2_raio, y);
    
    // BAGUNÇA A DIREÇÃO (ISSO CRIA O EFEITO DE RAIO)
    var variacao = random_range(-intensidade, intensidade);

    // DIREÇÃO FINAL = DIREÇÃO CERTA + BAGUNÇA
    var dir_final = dir_base + variacao;

    // DISTÂNCIA ATÉ O MOUSE
    var dist = point_distance(atual_x, atual_y, x2_raio, y);
    
    // TAMANHO DO PASSO
    // (DIVIDE A DISTÂNCIA PELO TANTO DE PEDAÇOS QUE FALTAM)
    var passo = dist / (qtd_segmentos - i);

    // CALCULA O PRÓXIMO PONTO DO RAIO
    var prox_x = atual_x + lengthdir_x(passo, dir_final);
    var prox_y = atual_y + lengthdir_y(passo, dir_final);

    // SE FOR O ÚLTIMO PEDAÇO...
    if (i == qtd_segmentos - 1)
    {
        // ...GRUDA EXATAMENTE NO MOUSE
        prox_x = x2_raio;
        prox_y = y;
    }

    // DESENHA UMA LINHA DO PONTO ATUAL ATÉ O PRÓXIMO
	draw_line_width_colour(atual_x, atual_y, prox_x, prox_y, tam_raio, _cor, _cor);

    // AGORA O "ATUAL" VIRA O PRÓXIMO
    // (ISSO FAZ O RAIO CONTINUAR DE ONDE PAROU)
    atual_x = prox_x;
    atual_y = prox_y;
}
//AS DUAS CAPSULAS NAS PONTAS
draw_sprite(spr_laser_cpsula, 0,x - 5, y)
draw_sprite(spr_laser_cpsula, 1,x2_raio, y)