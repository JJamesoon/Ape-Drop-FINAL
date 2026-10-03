//BLOCO RAIO: PINTA O OBJETO DE AZUL AQUA PELO BRILHO DO PIXEL (ESCURO = AZUL ESCURO, MEIO = AQUA, CLARO = BRANCO)
//SO OS OBJETOS USAM (PLAYER, BLOCOS, INIMIGO). O FUNDO E O RESTO DA TELA FICAM NORMAIS
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_raio;	//0 A 1: QUANTO O OBJETO FICA AQUA

void main()
{
    vec4 cor = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    float l = dot(cor.rgb, vec3(0.299, 0.587, 0.114));
    vec3 escuro = vec3(0.01, 0.09, 0.16);
    vec3 aqua = vec3(0.19, 0.99, 1.0);
    vec3 tom = l < 0.55 ? mix(escuro, aqua, l / 0.55) : mix(aqua, vec3(1.0), (l - 0.55) / 0.45);
    cor.rgb = mix(cor.rgb, tom, u_raio);
    gl_FragColor = cor;
}
