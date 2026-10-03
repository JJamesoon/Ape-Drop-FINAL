//ACERTOU O PLAYER: EMPURRA ELE PRO LADO CONTRARIO DA BALA (BALA REBATIDA PELO REFLEXO NAO MACHUCA)
if(refletida) exit;
if(global.game_pause) exit; //TIRO PARADO NO AR (TEMPO PARADO): NAO MACHUCA
other.levar_dano(sign(other.x - x));
instance_destroy();
