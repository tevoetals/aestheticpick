#!/usr/bin/env bash
set -euo pipefail

# ============================
#  AESTHETIC-PICK (picker)                            # seção: menu com rótulos estilizados
#  Arquivo: ~/.local/bin/aesthetic-pick               # caminho esperado pelo atalho e .desktop
#  Saída: variável $selection (nome do estilo); sai 1 se cancelar
# ============================

# ---------- ordem canônica dos estilos (chave técnica) ----------
order=(                                              # ordem que será usada para mapear índice→estilo
  mini                                              # 0
  oldenglish                                        # 1
  oldenglishbold                                    # 2
  handwriting                                       # 3
  handwritingbold                                   # 4
  chanfrado                                         # 5
  evensized                                         # 6
  inverse                                           # 7
  blackboxed                                        # 8
  circleboxed                                       # 9
  serifbold                                         # 10
  italic                                            # 11
  bold                                              # 12
  mono                                              # 13
  witched                                           # 14
)

# ---------- rótulos renderizados para exibir no rofi ----------
declare -A label                                    # mapa: estilo → rótulo bonito exibido no menu
label[mini]='ᴹⁱⁿⁱ'                                  # Mini
label[oldenglish]='𝔒𝔩𝔡 𝔈𝔫𝔤𝔩𝔦𝔰𝔥'                    # Fraktur normal
label[oldenglishbold]='𝕺𝖑𝖉 𝕰𝖓𝖌𝖑𝖎𝖘𝖍 𝕭𝖔𝖑𝖉'          # Fraktur negrito
label[handwriting]='𝓗𝓪𝓷𝓭 𝓦𝓻𝓲𝓽𝓲𝓷𝓰'                # Script/caligrafia
label[handwritingbold]='𝐻𝒶𝓃𝒹 𝒲𝓇𝒾𝓉𝒾𝓃𝑔 𝐵𝑜𝓁𝒹'        # Script negrito
label[chanfrado]='ℂ𝕙𝕒𝕟𝕗𝕣𝕒𝕕𝕠'                        # Double-struck
label[evensized]='ᴇᴠᴇɴꜱɪᴢᴇᴅ'                        # Small-caps
label[inverse]='ǝsɹǝʌuI'                             # Invertido (texto invertido como preview)
label[blackboxed]='🅱🅻🅰🅲🅺 🅱🅾🆇🅴🅳'                # BLACK BOXED
label[circleboxed]='Ⓒⓘⓡⓒⓛⓔ Ⓑⓞⓧⓔⓓ'                 # CIRCLE BOXED
label[serifbold]='𝐒𝐞𝐫𝐢𝐟 𝐁𝐨𝐥𝐝'                       # Serif Bold matemático
label[italic]='𝘐𝘵𝘢𝘭𝘪𝘤'                               # Itálico matemático
label[bold]='𝘽𝙤𝙡𝙙'                                   # Sans-serif bold/italic
label[mono]='𝙼𝚘𝚗𝚘'                                   # Monoespaçado
label[witched]='W҉i҉t҉c҉h҉e҉d҉'                       # Witched

# ---------- alimenta o rofi e recupera o índice escolhido ----------
menu_content="$(printf '%s\n' "${order[@]}" | while read -r k; do printf '%s\n' "${label[$k]}"; done)"  # lista de rótulos
idx="$(
  printf '%s\n' "$menu_content" \
  | /usr/bin/rofi -no-config -dmenu -i -p 'Aesthetic' -no-custom -format i -lines 15 -width 36 -selected-row 0 \
                  -theme "$HOME/.local/bin/aesthetic-black.rasi"            # -format i: retorna o índice da linha
)"
[[ "${idx:-"-1"}" == "-1" ]] && exit 1                                      # cancelado → sai 1
selection="${order[$idx]}"                                                  # mapeia índice → nome técnico do estilo

# ============================
#  AESTHETIC-APPLY (Wayland/X11)                   # captura PRIMÁRIA e aplica mapeamento/colagem
# ============================

# ---------- detecção de sessão e binários ----------
SESSION_TYPE="${XDG_SESSION_TYPE:-}"                                        # lê tipo de sessão (x11|wayland|vazio)
ROFI_BIN="/usr/bin/rofi"                                                    # caminho do rofi (não usado abaixo; referência)
command -v xclip   >/dev/null 2>&1 || true                                  # checagem opcional (X11)
command -v xdotool >/dev/null 2>&1 || true                                  # checagem opcional (X11)
command -v wl-paste>/dev/null 2>&1 || true                                  # checagem opcional (Wayland)

# ---------- captura da seleção PRIMÁRIA ----------
if [[ "${SESSION_TYPE}" == "x11" ]] && command -v xclip >/dev/null 2>&1; then
  INPUT="$(xclip -o -selection primary 2>/dev/null || true)"                # X11: lê PRIMÁRIA
elif [[ "${SESSION_TYPE}" == "wayland" ]] && command -v wl-paste >/dev/null 2>&1; then
  INPUT="$(wl-paste --primary 2>/dev/null || true)"                          # Wayland: lê PRIMÁRIA
else
  INPUT=""                                                                   # sem suporte de leitura
fi
[[ -z "${INPUT}" ]] && exit 0                                                # nada selecionado → nada a fazer

# ---------- utilitário de mapeamento 1:1 ----------
map_with_pairs() {                                                           # aplica pares k=v preservando não mapeados
  local text="$1"; shift                                                     # $1 texto; demais = pares k=v
  declare -A M=(); local p k v                                              # mapa e tmp
  for p in "$@"; do k="${p%%=*}"; v="${p#*=}"; [[ -n "$k" ]] && M["$k"]="$v"; done  # carrega mapa
  local out=""; local i ch                                                  # acumulador e cursores
  for ((i=0; i<${#text}; i++)); do                                          # percorre (ASCII de interesse)
    ch="${text:i:1}"                                                        # caractere atual
    if [[ -n "${M[$ch]+_}" ]]; then out+="${M[$ch]}"; else out+="$ch"; fi   # substitui ou mantém
  done
  printf '%s' "$out"                                                        # retorna convertido
}

# ---------- tabelas (estilos) ----------
build_pairs_serifbold() {                                                    # serif bold: a–z A–Z 0–9
  cat <<'EOF'
a=𝐚 b=𝐛 c=𝐜 d=𝐝 e=𝐞 f=𝐟 g=𝐠 h=𝐡 i=𝐢 j=𝐣 k=𝐤 l=𝐥 m=𝐦 n=𝐧 o=𝐨 p=𝐩 q=𝐪 r=𝐫 s=𝐬 t=𝐭 u=𝐮 v=𝐯 w=𝐰 x=𝐱 y=𝐲 z=𝐳
A=𝐀 B=𝐁 C=𝐂 D=𝐃 E=𝐄 F=𝐅 G=𝐆 H=𝐇 I=𝐈 J=𝐉 K=𝐊 L=𝐋 M=𝐌 N=𝐍 O=𝐎 P=𝐏 Q=𝐐 R=𝐑 S=𝐒 T=𝐓 U=𝐔 V=𝐕 W=𝐖 X=𝐗 Y=𝐘 Z=𝐙
0=𝟎 1=𝟏 2=𝟐 3=𝟑 4=𝟒 5=𝟓 6=𝟔 7=𝟕 8=𝟖 9=𝟗
EOF
}
build_pairs_italic() {                                                       # itálico: a–z A–Z
  cat <<'EOF'
a=𝘢 b=𝘣 c=𝘤 d=𝘥 e=𝘦 f=𝘧 g=𝘨 h=𝘩 i=𝘪 j=𝘫 k=𝘬 l=𝘭 m=𝘮 n=𝘯 o=𝘰 p=𝘱 q=𝘲 r=𝘳 s=𝘴 t=𝘵 u=𝘶 v=𝘷 w=𝘸 x=𝘹 y=𝘺 z=𝘻
A=𝘈 B=𝘉 C=𝘊 D=𝘋 E=𝘌 F=𝘍 G=𝘎 H=𝘏 I=𝘐 J=𝘑 K=𝘒 L=𝘓 M=𝘔 N=𝘕 O=𝘖 P=𝘗 Q=𝘘 R=𝘙 S=𝘚 T=𝘛 U=𝘜 V=𝘝 W=𝘞 X=𝘟 Y=𝘠 Z=𝘡
EOF
}
build_pairs_mono() {                                                         # mono: a–z A–Z
  cat <<'EOF'
a=𝚊 b=𝚋 c=𝚌 d=𝚍 e=𝚎 f=𝚏 g=𝚐 h=𝚑 i=𝚒 j=𝚓 k=𝚔 l=𝚕 m=𝚖 n=𝚗 o=𝚘 p=𝚙 q=𝚚 r=𝚛 s=𝚜 t=𝚝 u=𝚞 v=𝚟 w=𝚠 x=𝚡 y=𝚢 z=𝚣
A=𝙰 B=𝙱 C=𝙲 D=𝙳 E=𝙴 F=𝙵 G=𝙶 H=𝙷 I=𝙸 J=𝙹 K=𝙺 L=𝙻 M=𝙼 N=𝙽 O=𝙾 P=𝙿 Q=𝚀 R=𝚁 S=𝚂 T=𝚃 U=𝚄 V=𝚅 W=𝚆 X=𝚇 Y=𝚈 Z=𝚉
EOF
}
build_pairs_mini() {                                                         # mini: minúsculas+MAIÚSCULAS+dígitos
  cat <<'EOF'
a=ᵃ b=ᵇ c=ᶜ d=ᵈ e=ᵉ f=ᶠ g=ᵍ h=ʰ i=ⁱ j=ʲ k=ᵏ l=ˡ m=ᵐ n=ⁿ o=ᵒ p=ᵖ q=q r=ʳ s=ˢ t=ᵗ u=ᵘ v=ᵛ w=ʷ x=ˣ y=ʸ z=ᶻ
A=ᴬ B=ᴮ C=ᶜ D=ᴰ E=ᴱ F=ᶠ G=ᴳ H=ᴴ I=ᴵ J=ᴶ K=ᴷ L=ᴸ M=ᴹ N=ᴺ O=ᴼ P=ᴾ Q=Q R=ᴿ S=ˢ T=ᵀ U=ᵁ V=ⱽ W=ᵂ X=ˣ Y=ʸ Z=ᶻ
0=⁰ 1=¹ 2=² 3=³ 4=⁴ 5=⁵ 6=⁶ 7=⁷ 8=⁸ 9=⁹
EOF
}
build_pairs_bold() {                                                         # bold (sans-serif): a–z A–Z
  cat <<'EOF'
a=𝙖 b=𝙗 c=𝙘 d=𝙙 e=𝙚 f=𝙛 g=𝙜 h=𝙝 i=𝙞 j=𝙟 k=𝙠 l=𝙡 m=𝙢 n=𝙣 o=𝙤 p=𝙥 q=𝙦 r=𝙧 s=𝙨 t=𝙩 u=𝙪 v=𝙫 w=𝙬 x=𝙭 y=𝙮 z=𝙯
A=𝘼 B=𝘽 C=𝘾 D=𝘿 E=𝙀 F=𝙁 G=𝙂 H=𝙃 I=𝙄 J=𝙅 K=𝙆 L=𝙇 M=𝙈 N=𝙉 O=𝙊 P=𝙋 Q=𝙌 R=𝙍 S=𝙎 T=𝙏 U=𝙐 V=𝙑 W=𝙒 X=𝙓 Y=𝙔 Z=𝙕
EOF
}
build_pairs_italic_bold() {                                                  # italic bold (compatível com pedido anterior)
  cat <<'EOF'
a=𝙖 b=𝙗 c=𝙘 d=𝙙 e=𝙚 f=𝙛 g=𝙜 h=𝙝 i=𝙞 j=𝙟 k=𝙠 l=𝙡 m=𝙢 n=𝙣 o=𝙤 p=𝙥 q=𝙦 r=𝙧 s=𝙨 t=𝙩 u=𝙪 v=𝙫 w=𝙬 x=𝙭 y=𝙮 z=𝙯
A=𝘼 B=𝘽 C=𝘾 D=𝘿 E=𝙀 F=𝙁 G=𝙂 H=𝙃 I=𝙄 J=𝙅 K=𝙆 L=𝙇 M=𝙈 N=𝙉 O=𝙊 P=𝙋 Q=𝙌 R=𝙍 S=𝙎 T=𝙏 U=𝙐 V=𝙑 W=𝙒 X=𝙓 Y=𝙔 Z=𝙕
EOF
}
build_pairs_fraktur() {                                                       # fraktur (oldenglish)
  cat <<'EOF'
a=𝔞 b=𝔟 c=𝔠 d=𝔡 e=𝔢 f=𝔣 g=𝔤 h=𝔥 i=𝔦 j=𝔧 k=𝔨 l=𝔩 m=𝔪 n=𝔫 o=𝔬 p=𝔭 q=𝔮 r=𝔯 s=𝔰 t=𝔱 w=𝔴 x=𝔵 y=𝔶 z=𝔷
A=𝔄 B=𝔅 C=ℭ D=𝔇 E=𝔈 F=𝔉 G=𝔊 H=ℌ I=ℑ J=𝔍 K=𝔎 L=𝔏 M=𝔐 N=𝔑 O=𝔒 P=𝔓 Q=𝔔 R=ℜ S=𝔖 T=𝔗 W=𝔚 X=𝔛 Y=𝔜 Z=ℨ
EOF
}
build_pairs_fraktur_bold() {                                                  # fraktur negrito (oldenglishbold)
  cat <<'EOF'
a=𝖆 b=𝖇 c=𝖈 d=𝖉 e=𝖊 f=𝖋 g=𝖌 h=𝖍 i=𝖎 j=𝖏 k=𝖐 l=𝖑 m=𝖒 n=𝖓 o=𝖔 p=𝖕 q=𝖖 r=𝖗 s=𝖘 t=𝖙 w=𝖜 x=𝖝 y=𝖞 z=𝖟
A=𝕬 B=𝕭 C=𝕮 D=𝕯 E=𝕰 F=𝕱 G=𝕲 H=𝕳 I=𝕴 J=𝕵 K=𝕶 L=𝕷 M=𝕸 N=𝕹 O=𝕺 P=𝕻 Q=𝕼 R=𝕽 S=𝕾 T=𝕿 W=𝖂 X=𝖃 Y=𝖄 Z=𝖅
EOF
}
build_pairs_script() {                                                        # script (handwriting)
  cat <<'EOF'
a=𝓪 b=𝓫 c=𝓬 d=𝓭 e=𝓮 f=𝓯 g=𝓰 h=𝓱 i=𝓲 j=𝓳 k=𝓴 l=𝓵 m=𝓶 n=𝓷 o=𝓸 p=𝓹 q=𝓺 r=𝓻 s=𝓼 t=𝓽 w=𝔀 x=𝔁 y=𝔂 z=𝔃
A=𝓐 B=𝓑 C=𝓒 D=𝓓 E=𝓔 F=𝓕 G=𝓖 H=𝓗 I=𝓘 J=𝓙 K=𝓚 L=𝓛 M=𝓜 N=𝓝 O=𝓞 P=𝓟 Q=𝓠 R=𝓡 S=𝓢 T=𝓣 W=𝓦 X=𝓧 Y=𝓨 Z=𝓩
EOF
}
build_pairs_script_bold() {                                                   # script negrito (handwritingbold)
  cat <<'EOF'
a=𝒶 b=𝒷 c=𝒸 d=𝒹 e=𝑒 f=𝒻 g=𝑔 h=𝒽 i=𝒾 j=𝒿 k=𝓀 l=𝓁 m=𝓂 n=𝓃 o=𝑜 p=𝓅 q=𝓆 r=𝓇 s=𝓈 t=𝓉 w=𝓌 x=𝓍 y=𝓎 z=𝓏
A=𝒜 B=𝐵 C=𝒞 D=𝒟 E=𝐸 F=𝐹 G=𝒢 H=𝐻 I=𝐼 J=𝒥 K=𝒦 L=𝐿 M=𝑀 N=𝒩 O=𝒪 P=𝒫 Q=𝒬 R=𝑅 S=𝒮 T=𝒯 W=𝒲 X=𝒳 Y=𝒴 Z=𝒵
0=𝟢 1=𝟣 2=𝟤 3=𝟥 4=𝟦 5=𝟧 6=𝟨 7=𝟩 8=𝟪 9=𝟫
EOF
}
build_pairs_double_struck() {                                                 # double-struck (chanfrado)
  cat <<'EOF'
a=𝕒 b=𝕓 c=𝕔 d=𝕕 e=𝕖 f=𝕗 g=𝕘 h=𝕙 i=𝕚 j=𝕛 k=𝕜 l=𝕝 m=𝕞 n=𝕟 o=𝕠 p=𝕡 q=𝕢 r=𝕣 s=𝕤 t=𝕥 w=𝕨 x=𝕩 y=𝕪 z=𝕫
A=𝔸 B=𝔹 C=ℂ D=𝔻 E=𝔼 F=𝔽 G=𝔾 H=ℍ I=𝕀 J=𝕁 K=𝕂 L=𝕃 M=𝕄 N=ℕ O=𝕆 P=ℙ Q=ℚ R=ℝ S=𝕊 T=𝕋 W=𝕎 X=𝕏 Y=𝕐 Z=ℤ
0=𝟘 1=𝟙 2=𝟚 3=𝟛 4=𝟜 5=𝟝 6=𝟞 7=𝟟 8=𝟠 9=𝟡
EOF
}
build_pairs_small_caps() {                                                    # small caps (evensized)
  cat <<'EOF'
a=ᴀ b=ʙ c=ᴄ d=ᴅ e=ᴇ f=ꜰ g=ɢ h=ʜ i=ɪ j=ᴊ k=ᴋ l=ʟ m=ᴍ n=ɴ o=ᴏ p=ᴘ q=Q r=ʀ s=ꜱ t=ᴛ u=ᴜ v=ᴠ w=ᴡ x=x y=ʏ z=ᴢ
A=ᴀ B=ʙ C=ᴄ D=ᴅ E=ᴇ F=ꜰ G=ɢ H=ʜ I=ɪ J=ᴊ K=ᴋ L=ʟ M=ᴍ N=ɴ O=ᴏ P=ᴘ Q=Q R=ʀ S=ꜱ T=ᴛ U=ᴜ V=ᴠ W=ᴡ X=x Y=ʏ Z=ᴢ
EOF
}
build_pairs_blackboxed() {                                                    # black boxed: mapear minúsculas/maiúsculas → 🅰…🆉
  cat <<'EOF'
a=🅰 b=🅱 c=🅲 d=🅳 e=🅴 f=🅵 g=🅶 h=🅷 i=🅸 j=🅹 k=🅺 l=🅻 m=🅼 n=🅽 o=🅾 p=🅿 q=🆀 r=🆁 s=🆂 t=🆃 u=🆄 v=🆅 w=🆆 x=🆇 y=🆈 z=🆉
A=🅰 B=🅱 C=🅲 D=🅳 E=🅴 F=🅵 G=🅶 H=🅷 I=🅸 J=🅹 K=🅺 L=🅻 M=🅼 N=🅽 O=🅾 P=🅿 Q=🆀 R=🆁 S=🆂 T=🆃 U=🆄 V=🆅 W=🆆 X=🆇 Y=🆈 Z=🆉
EOF
}
build_pairs_circleboxed() {                                                   # circle boxed: a–z A–Z 0–9
  cat <<'EOF'
a=ⓐ b=ⓑ c=ⓒ d=ⓓ e=ⓔ f=ⓕ g=ⓖ h=ⓗ i=ⓘ j=ⓙ k=ⓚ l=ⓛ m=ⓜ n=ⓝ o=ⓞ p=ⓟ q=ⓠ r=ⓡ s=ⓢ t=ⓣ u=ⓤ v=ⓥ w=ⓦ x=ⓧ y=ⓨ z=ⓩ
A=Ⓐ B=Ⓑ C=Ⓒ D=Ⓓ E=Ⓔ F=Ⓕ G=Ⓖ H=Ⓗ I=Ⓘ J=Ⓙ K=Ⓚ L=Ⓛ M=Ⓜ N=Ⓝ O=Ⓞ P=Ⓟ Q=Ⓠ R=Ⓡ S=Ⓢ T=Ⓣ U=Ⓤ V=Ⓥ W=Ⓦ X=Ⓧ Y=Ⓨ Z=Ⓩ
0=⓪ 1=① 2=② 3=③ 4=④ 5=⑤ 6=⑥ 7=⑦ 8=⑧ 9=⑨
EOF
}

# ---------- especiais (procedurais) ----------
apply_inverse() {                                                             # inverse: mapeia upside-down e reverte string
  local text="$1"                                                              # entrada
  local pairs=(                                                                # pares upside-down básicos
    "a=ɐ" "b=q" "c=ɔ" "d=p" "e=ǝ" "f=ɟ" "g=ƃ" "h=ɥ" "i=ᴉ" "j=ɾ" "k=ʞ" "l=ʃ" "m=ɯ" "n=u" "o=o" "p=d" "q=b" "r=ɹ" "s=s" "t=ʇ" "u=n" "v=ʌ" "w=ʍ" "x=x" "y=ʎ" "z=z"
    "A=∀" "B=ᙠ" "C=Ɔ" "D=ᗡ" "E=Ǝ" "F=Ⅎ" "G=⅁" "H=H" "I=I" "J=ſ" "K=ʞ" "L=˥" "M=W" "N=N" "O=O" "P=Ԁ" "Q=Ό" "R=ᴚ" "S=S" "T=⊥" "U=∩" "V=Λ" "W=ʍ" "X=X" "Y=⅄" "Z=Z"
    "0=0" "1=Ɩ" "2=ᄅ" "3=Ɛ" "4=ㄣ" "5=ϛ" "6=9" "7=ㄥ" "8=8" "9=6"
  )
  local mapped; mapped="$(map_with_pairs "$text" "${pairs[@]}")"               # aplica mapeamento
  local out=""; for ((i=${#mapped}-1;i>=0;i--)); do out+="${mapped:i:1}"; done # inverte ordem
  printf '%s' "$out"                                                           # retorna
}
apply_witched() {                                                             # witched: adiciona diacríticos “bagunça”
  local text="$1"                                                              # entrada
  local combo=$'\u0336\u0335\u034f\u0316\u0317\u0334\u0301\u0300'             # marks combinantes
  local out=""; for ((i=0;i<${#text};i++)); do out+="${text:i:1}${combo}"; done # injeta após cada char
  printf '%s' "$out"                                                           # retorna
}

# ---------- roteador por $selection ----------
case "$selection" in
  serifbold)         OUTPUT="$(map_with_pairs "$INPUT" $(build_pairs_serifbold))"       ;;  # 𝐀…𝟗
  bold)              OUTPUT="$(map_with_pairs "$INPUT" $(build_pairs_bold))"            ;;  # 𝘼… / 𝙖…
  italic)            OUTPUT="$(map_with_pairs "$INPUT" $(build_pairs_italic))"          ;;  # 𝘐… / 𝘪…
  "italic bold")     OUTPUT="$(map_with_pairs "$INPUT" $(build_pairs_italic_bold))"     ;;  # compat
  mono)              OUTPUT="$(map_with_pairs "$INPUT" $(build_pairs_mono))"            ;;  # 𝙼… / 𝚖…
  mini)              OUTPUT="$(map_with_pairs "$INPUT" $(build_pairs_mini))"            ;;  # ᴹⁱⁿⁱ …
  oldenglish)        OUTPUT="$(map_with_pairs "$INPUT" $(build_pairs_fraktur))"         ;;  # 𝔄… / 𝔞…
  oldenglishbold)    OUTPUT="$(map_with_pairs "$INPUT" $(build_pairs_fraktur_bold))"    ;;  # 𝕬… / 𝖆…
  handwriting)       OUTPUT="$(map_with_pairs "$INPUT" $(build_pairs_script))"          ;;  # 𝓐… / 𝓪…
  handwritingbold)   OUTPUT="$(map_with_pairs "$INPUT" $(build_pairs_script_bold))"     ;;  # 𝒜… / 𝒶…
  chanfrado)         OUTPUT="$(map_with_pairs "$INPUT" $(build_pairs_double_struck))"   ;;  # 𝔸… / 𝕒…
  evensized)         OUTPUT="$(map_with_pairs "$INPUT" $(build_pairs_small_caps))"      ;;  # ᴬ… / ᴀ…
  blackboxed)        OUTPUT="$(map_with_pairs "$INPUT" $(build_pairs_blackboxed))"      ;;  # 🅰… (sempre)
  circleboxed)       OUTPUT="$(map_with_pairs "$INPUT" $(build_pairs_circleboxed))"     ;;  # Ⓐ… ①…
  inverse)           OUTPUT="$(apply_inverse "$INPUT")"                                 ;;  # upside-down
  witched)           OUTPUT="$(apply_witched "$INPUT")"                                 ;;  # diacríticos
  *)                 OUTPUT="$INPUT"                                                    ;;  # fallback
esac

# ---------- colagem: PRIMÁRIA (se suportar) OU clipboard com atalho configurável ----------
AESTHETIC_DELAY="${AESTHETIC_DELAY:-0.70}"                                    # espera foco voltar do rofi
PASTE_DELAY="${PASTE_DELAY:-0.06}"                                            # espera curta para propagação
PASTE_MODE="${AESTHETIC_PASTE_SEQ:-auto}"                                     # auto|ctrlv|ctrlshiftv|shiftinsert
USE_CLIP="${AESTHETIC_FALLBACK_CLIP:-1}"                                      # 0 usa PRIMÁRIA; 1 usa clipboard (recomendado p/ web)

yd_paste_keys() {                                                             # dispara sequência via ydotool
  case "$1" in
    ctrlv)        ydotool key 29:1 47:1 47:0 29:0 ;;                          # Ctrl(29)+V(47)
    ctrlshiftv)   ydotool key 42:1 29:1 47:1 47:0 29:0 42:0 ;;                # Shift(42)+Ctrl(29)+V(47)
    shiftinsert)  ydotool key 42:1 110:1 110:0 42:0 ;;                        # Shift(42)+Insert(110)
    *)            ydotool key 29:1 47:1 47:0 29:0 ;;                          # default: Ctrl+V
  esac
}
decide_mode() {                                                               # heurística: terminal → Ctrl+Shift+V
  case "${PASTE_MODE}" in
    auto)
      if [[ -n "${TERM_PROGRAM:-}" || -n "${KONSOLE_VERSION:-}" || -n "${TERMINAL_EMULATOR:-}" ]]; then
        printf '%s' "ctrlshiftv"                                              # terminal
      else
        printf '%s' "ctrlv"                                                   # campos web/apps comuns
      fi
      ;;
    *) printf '%s' "${PASTE_MODE}";;
  esac
}

if [[ "${SESSION_TYPE}" == "wayland" ]]; then                                 # Wayland
  sleep "${AESTHETIC_DELAY}"                                                  # deixa foco estabilizar
  if [[ "${USE_CLIP}" == "0" ]]; then                                         # tentar PRIMÁRIA
    command -v wl-copy >/dev/null 2>&1 || { echo "wl-copy ausente" >&2; exit 1; }
    printf '%s' "$OUTPUT" | wl-copy --primary --paste-once                    # escreve PRIMÁRIA
    sleep "${PASTE_DELAY}"                                                    # pequena espera
    ydotool click 2                                                           # middle-click
  else                                                                        # usar clipboard + atalho
    command -v wl-copy >/dev/null 2>&1 || { echo "wl-copy ausente" >&2; exit 1; }
    OLDC="$(wl-paste 2>/dev/null || true)"                                    # salva clipboard atual
    printf '%s' "$OUTPUT" | wl-copy                                           # define clipboard com resultado
    sleep "${PASTE_DELAY}"                                                    # pequena espera
    MODE="$(decide_mode)"                                                     # escolhe sequência
    yd_paste_keys "$MODE"                                                     # dispara colagem
    printf '%s' "$OLDC" | wl-copy                                             # restaura clipboard
  fi

elif [[ "${SESSION_TYPE}" == "x11" ]]; then                                   # X11
  if [[ "${USE_CLIP}" == "0" ]]; then                                         # PRIMÁRIA
    command -v xclip >/dev/null 2>&1 || { echo "xclip ausente" >&2; exit 1; }
    printf '%s' "$OUTPUT" | xclip -selection primary -i                       # escreve PRIMÁRIA
    sleep "${PASTE_DELAY}"                                                    # espera
    xdotool click 2                                                           # middle-click
  else                                                                        # clipboard + Ctrl+V
    OLDX="$(xclip -o -selection clipboard 2>/dev/null || true)"               # salva clipboard
    printf '%s' "$OUTPUT" | xclip -selection clipboard -i                     # define clipboard
    sleep "${PASTE_DELAY}"                                                    # espera
    xdotool key ctrl+v                                                        # cola
    printf '%s' "$OLDX" | xclip -selection clipboard -i                       # restaura clipboard
  fi

else
  echo "Sessão desconhecida." >&2; exit 1                                      # ambiente não reconhecido
fi

# ---------- diagnóstico opcional ----------
if [[ "${AESTHETIC_DEBUG:-}" == "1" ]]; then                                  # logs quando ativado
  {
    echo "[AESTHETIC] session=${SESSION_TYPE:-unknown}"                        # tipo de sessão
    echo "[AESTHETIC] tools: wl-copy=$(command -v wl-copy >/dev/null 2>&1 && echo yes || echo no) ydotool=$(command -v ydotool >/dev/null 2>&1 && echo yes || echo no) xclip=$(command -v xclip >/dev/null 2>&1 && echo yes || echo no) xdotool=$(command -v xdotool >/dev/null 2>&1 && echo yes || echo no)"
    echo "[AESTHETIC] selection='$selection'"                                  # estilo escolhido
    echo "[AESTHETIC] input_len=${#INPUT} output_len=${#OUTPUT}"               # tamanhos
    echo "[AESTHETIC] first20_in='$(printf '%s' "$INPUT"  | head -c 20 | tr '\n' ' ' )'"    # amostra IN
    echo "[AESTHETIC] first20_out='$(printf '%s' "$OUTPUT" | head -c 20 | tr '\n' ' ' )'"   # amostra OUT
  } >> /tmp/aesthetic-debug.log                                                # escreve em /tmp
fi                                                                             # fim
