//ONDA DE CHOQUE (ESTILO CELESTE): UM ANEL QUE CRESCE E DISTORCE A TELA POR ONDE PASSA
//ATE 4 ONDAS AO MESMO TEMPO. CADA UMA: CENTRO (0-1), RAIO (PX) E FORÇA (PX). FORÇA 0 = DESLIGADA
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_tela;		//TAMANHO DA TELA EM PX
uniform vec4 u_ondas[4];
uniform float u_largura;	//LARGURA DO ANEL EM PX
//CALOR DO LASER (ATE 3): RETANGULO (X1, Y1, X2, Y2 DE 0 A 1) E INFO (FASE 0-1 DA ONDA QUE DESCE, FORÇA PX, TEMPO, ALTURA DA ONDA PX)
uniform vec4 u_calor[3];
uniform vec4 u_calor_info[3];
//TEMPO PARADO: QUANTO A TELA FICA VERDE (0-1) E INFO (CENTRO X/Y 0-1, RAIO DO ANEL DO RELOGIO PX, LARGURA DO ANEL PX)
uniform float u_parado;
uniform vec4 u_parado_info;

void main()
{
    //QUANTO O PIXEL VAI SER EMPURRADO E QUANTO BRILHA
    vec2 desloc = vec2(0.0);
    float brilho = 0.0;
    for(int i = 0; i < 4; i++)
    {
        vec4 o = u_ondas[i];
        //ONDA LIGADA (FORÇA > 0)
        if(o.w > 0.0)
        {
            //DISTANCIA DO PIXEL ATE O CENTRO DA ONDA (EM PX)
            vec2 d = (v_vTexcoord - o.xy) * u_tela;
            float dist = length(d);
            //POSIÇAO DENTRO DO ANEL: -1 A 1 (FORA DISSO O PIXEL NAO E AFETADO)
            float t = (dist - o.z) / u_largura;
            if(abs(t) < 1.0 && dist > 0.001)
            {
                float a = cos(t * 1.5707963);	//1 NO MEIO DO ANEL, 0 NAS BORDAS
                //EMPURRA O PIXEL NA DIREÇAO DO CENTRO
                desloc -= (d / dist) * a * o.w;
                brilho += a * o.w * 0.004; //SO UM BRILHO LEVE NO ANEL
            }
        }
    }
    //CALOR: DENTRO DO RETANGULO DO LASER A TELA ONDULA DE LEVE, MAIS FORTE NA FAIXA QUE VAI DO TOPO AO CHAO
    vec2 px = v_vTexcoord * u_tela;
    for(int i = 0; i < 3; i++)
    {
        vec4 inf = u_calor_info[i];
        if(inf.y > 0.0)
        {
            vec2 a = u_calor[i].xy * u_tela;
            vec2 b = u_calor[i].zw * u_tela;
            float m = inf.w * 0.5;	//BORDA DOS LADOS SUAVE
            float bx = smoothstep(a.x - m, a.x, px.x) * (1.0 - smoothstep(b.x, b.x + m, px.x));
            if(bx > 0.0 && px.y >= a.y && px.y <= b.y)
            {
                float yc = mix(a.y, b.y, inf.x);
                float faixa = max(0.0, 1.0 - abs(px.y - yc) / inf.w);
                float k = (0.3 + faixa) * bx;
                desloc.x += sin(px.y * 0.12 + inf.z * 0.35) * inf.y * k;
                desloc.y += cos(px.x * 0.2 + inf.z * 0.25) * inf.y * 0.4 * faixa * bx;
                brilho += faixa * bx * 0.025;
            }
        }
    }
    //TEMPO PARADO: UM ANEL DO "RELOGIO" SAINDO DE ONDE O TEMPO PAROU, QUE ENTORTA A TELA DE LEVE
    float anel = 0.0;
    if(u_parado > 0.0)
    {
        vec2 dp = (v_vTexcoord - u_parado_info.xy) * u_tela;
        float distp = length(dp);
        anel = max(0.0, 1.0 - abs(distp - u_parado_info.z) / u_parado_info.w);
        if(distp > 0.001) desloc += (dp / distp) * anel * 3.0 * u_parado;
    }
    //PEGA A COR DO PIXEL DESLOCADO E SOMA O BRILHO
    vec4 cor = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord + desloc / u_tela);
    cor.rgb += brilho;
    //TEMPO PARADO: TUDO VIRA VERDE (PELO BRILHO DO PIXEL), COM AS BORDAS MAIS ESCURAS E O ANEL BRILHANDO
    if(u_parado > 0.0)
    {
        float l = dot(cor.rgb, vec3(0.299, 0.587, 0.114));
        vec2 cv = v_vTexcoord - 0.5;
        float vin = clamp(1.0 - dot(cv, cv) * 1.6, 0.0, 1.0);
        vec3 verde = vec3(l * 0.30, l * 1.05 + 0.05, l * 0.55) * (0.55 + 0.45 * vin);
        verde += vec3(0.25, 1.0, 0.55) * anel * 0.35;
        cor.rgb = mix(cor.rgb, verde, u_parado);
    }
    gl_FragColor = cor;
}
