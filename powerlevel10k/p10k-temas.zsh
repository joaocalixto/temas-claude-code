# Estilo do Powerlevel10k dos temas-claude-code.
#
# Blocos coloridos em duas linhas:
#   pasta  git                 ✔/✘  tempo do comando  Java  Node  hora
#   ❯
# Dois estilos de cores (troca com: prompt-estilo tema | prompt-estilo sobrio):
#   tema   - as cores seguem o tema do iTerm2 (Rengoku, Lofi Cidades, Cidade Pixel) e mudam
#            sozinhas quando usas o /tema. Noutro perfil usa as 16 cores desse perfil.
#   sobrio - azul-escuro com letra branca, igual em todos os temas.
# A escolha fica em ~/.claude/temas-prompt.txt.
#
# O instalar.command liga este arquivo no fim do ~/.zshrc (depois do teu ~/.p10k.zsh),
# por isso ele manda no estilo. Para voltares ao teu estilo antigo, apaga essas duas
# linhas do ~/.zshrc ou corre o desinstalar.command.

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

# ---------------------------------------------------------------------------
# Qual é o tema desta aba? Põe o nome do perfil em $REPLY ("" se não for um tema).
# A mesma ordem do lembrar.sh: o último /tema desta aba; senão o perfil com que a
# aba abriu; se esse perfil é o "Claude · Último", o tema que ele copia.
# ---------------------------------------------------------------------------
function _temas_p10k_tema() {
  emulate -L zsh -o extended_glob
  local id=${${ITERM_SESSION_ID#*:}//[^A-Za-z0-9-]/} t= f
  f=$HOME/.claude/.tema-por-aba/$id
  [[ -n $id && -r $f ]] && t="$(<$f)" && t=${t%%$'\n'*}
  [[ $t == 'Claude · '(Rengoku|'Lofi Cidades'|'Cidade Pixel') ]] || t=$ITERM_PROFILE
  if [[ $t == 'Claude · Último' ]]; then
    f="$HOME/Library/Application Support/iTerm2/DynamicProfiles/claude-ultimo.json"
    if [[ -r $f && "$(<$f)" == (#b)*'"Dynamic Profile Parent Name":'[[:space:]]#'"'([^\"]#)'"'* ]]; then
      t=$match[1]
    fi
  fi
  [[ $t == 'Claude · '(Rengoku|'Lofi Cidades'|'Cidade Pixel') ]] || t=
  typeset -g REPLY=$t
}

# ---------------------------------------------------------------------------
# Cores de cada tema (as mesmas de iterm2/temas-claude-code.json).
#   acc = cor principal do tema (a do cursor)   ok/aviso/erro = verde/amarelo/vermelho
#   esc/esc2 = blocos escuros   txt = letra clara   fundo = cor de fundo do tema
# ---------------------------------------------------------------------------
function _temas_p10k_cores() {
  emulate -L zsh
  local acc ok aviso erro esc esc2 txt fundo sobre
  case $1 in
    'Claude · Rengoku')
      acc='#ff7a3d' ok='#8fd694' aviso='#e8b04a' erro='#e5533d'
      esc='#4a3530' esc2='#5a2318' txt='#f3e6dd' fundo='#0e0907' ;;
    'Claude · Lofi Cidades')
      acc='#ff9b73' ok='#a6e3a1' aviso='#ffd86b' erro='#ff7a85'
      esc='#4d3d57' esc2='#4a2e3a' txt='#f4e9e2' fundo='#1a1322' ;;
    'Claude · Cidade Pixel')
      acc='#5ee6f0' ok='#7cf29a' aviso='#ffe066' erro='#ff5c7a'
      esc='#2a3a66' esc2='#1b335f' txt='#dde6ff' fundo='#070b1a' ;;
    *)  # outro perfil: as 16 cores dele
      acc=4 ok=2 aviso=3 erro=1 esc=8 esc2=0 txt=7 fundo=0 ;;
  esac
  sobre=$fundo                       # letra em cima dos blocos claros
  [[ -z $1 ]] && sobre=255           # no perfil comum, letra branca no bloco azul da pasta

  # pasta
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=$acc
  typeset -g POWERLEVEL9K_DIR_{FOREGROUND,SHORTENED_FOREGROUND,ANCHOR_FOREGROUND}=$sobre
  typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_BACKGROUND=$erro
  typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_{FOREGROUND,SHORTENED_FOREGROUND,ANCHOR_FOREGROUND}=$fundo

  # git: verde = tudo guardado, amarelo = há mudanças
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED}_BACKGROUND=$ok
  typeset -g POWERLEVEL9K_VCS_{MODIFIED,CONFLICTED}_BACKGROUND=$aviso
  typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=$esc
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED,CONFLICTED}_FOREGROUND=$fundo
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=$txt
  typeset -g _temas_git_txt="%F{$fundo}" _temas_git_conflito="%F{$erro}"

  # ✔ / ✘ do último comando
  typeset -g POWERLEVEL9K_STATUS_{OK,OK_PIPE}_FOREGROUND=$ok
  typeset -g POWERLEVEL9K_STATUS_{OK,OK_PIPE}_BACKGROUND=$esc
  typeset -g POWERLEVEL9K_STATUS_{ERROR,ERROR_SIGNAL,ERROR_PIPE}_FOREGROUND=$fundo
  typeset -g POWERLEVEL9K_STATUS_{ERROR,ERROR_SIGNAL,ERROR_PIPE}_BACKGROUND=$erro
  [[ -z $1 ]] && typeset -g POWERLEVEL9K_STATUS_{ERROR,ERROR_SIGNAL,ERROR_PIPE}_FOREGROUND=255

  # tempo do comando, Java, Node, hora
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$aviso
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=$esc2
  typeset -g POWERLEVEL9K_JAVA_VERSION_FOREGROUND=$acc
  typeset -g POWERLEVEL9K_JAVA_VERSION_BACKGROUND=$esc
  typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=$ok
  typeset -g POWERLEVEL9K_NODE_VERSION_BACKGROUND=$esc
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=$txt
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=$esc2

  # ❯ na linha de baixo: cor do tema, vermelho se o último comando falhou
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$acc
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$erro
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true

  [[ $2 == sobrio ]] || return 0
  # estilo sóbrio: tons de azul-escuro, letra branca, sem negrito
  local azul1='#1e3a5f' azul2='#172f4d' azul3='#10233a' azul4='#28507f' branco='#ffffff' vermelho='#8b2232'
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=$azul1
  typeset -g POWERLEVEL9K_DIR_{FOREGROUND,SHORTENED_FOREGROUND,ANCHOR_FOREGROUND}=$branco
  typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_BACKGROUND=$vermelho
  typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_{FOREGROUND,SHORTENED_FOREGROUND,ANCHOR_FOREGROUND}=$branco
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=false
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,LOADING}_BACKGROUND=$azul2
  typeset -g POWERLEVEL9K_VCS_{MODIFIED,CONFLICTED}_BACKGROUND=$azul4    # um azul mais claro quando há mudanças
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED,CONFLICTED,LOADING}_FOREGROUND=$branco
  typeset -g _temas_git_txt="%F{$branco}" _temas_git_conflito="%F{#ff8a8a}"
  typeset -g POWERLEVEL9K_STATUS_{OK,OK_PIPE}_FOREGROUND=$branco
  typeset -g POWERLEVEL9K_STATUS_{OK,OK_PIPE}_BACKGROUND=$azul3
  typeset -g POWERLEVEL9K_STATUS_{ERROR,ERROR_SIGNAL,ERROR_PIPE}_FOREGROUND=$branco
  typeset -g POWERLEVEL9K_STATUS_{ERROR,ERROR_SIGNAL,ERROR_PIPE}_BACKGROUND=$vermelho
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$branco
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=$azul2
  typeset -g POWERLEVEL9K_{JAVA,NODE}_VERSION_FOREGROUND=$branco
  typeset -g POWERLEVEL9K_{JAVA,NODE}_VERSION_BACKGROUND=$azul3
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=$branco
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=$azul1
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$branco
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#ff8a8a'
}

# o estilo escolhido em ~/.claude/temas-prompt.txt ("tema" se não houver)
function _temas_p10k_estilo() {
  emulate -L zsh
  local f=$HOME/.claude/temas-prompt.txt e=tema
  [[ -r $f ]] && e="$(<$f)" && e=${e%%$'\n'*}
  [[ $e == (tema|sobrio) ]] || e=tema
  typeset -g REPLY=$e
}

# prompt-estilo tema | sobrio  -> troca o estilo das cores (vale já no próximo prompt, em todas as abas)
function prompt-estilo() {
  emulate -L zsh
  case ${1:l} in
    tema)               print -r -- tema   >| $HOME/.claude/temas-prompt.txt ;;
    sobrio|sóbrio|azul) print -r -- sobrio >| $HOME/.claude/temas-prompt.txt ;;
    *) _temas_p10k_estilo; print -r -- "Estilo atual: $REPLY. Usa: prompt-estilo tema | prompt-estilo sobrio"; return ;;
  esac
}

# Antes de cada prompt: se o tema mudou (por exemplo com o /tema), troca as cores.
# O Powerlevel10k vê que as variáveis mudaram e redesenha sozinho.
function _temas_p10k_precmd() {
  local estilo
  _temas_p10k_estilo; estilo=$REPLY
  _temas_p10k_tema
  [[ "$estilo|$REPLY" == "$_temas_p10k_atual" ]] && return
  typeset -g _temas_p10k_atual="$estilo|$REPLY"
  _temas_p10k_cores "$REPLY" "$estilo"
}

# Mostra o git (o mesmo formato do estilo "rainbow" do Powerlevel10k).
function _temas_git_formato() {
  emulate -L zsh
  if [[ -n $P9K_CONTENT ]]; then
    typeset -g _temas_git=$P9K_CONTENT
    return
  fi
  local c=$_temas_git_txt x=$_temas_git_conflito res
  if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
    local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
    (( $#branch > 32 )) && branch[13,-13]="…"
    res+="${c}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${branch//\%/%%}"
  fi
  if [[ -n $VCS_STATUS_TAG && -z $VCS_STATUS_LOCAL_BRANCH ]]; then
    local tag=${(V)VCS_STATUS_TAG}
    (( $#tag > 32 )) && tag[13,-13]="…"
    res+="${c}#${tag//\%/%%}"
  fi
  [[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] && res+="${c}@${VCS_STATUS_COMMIT[1,8]}"
  if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
    res+="${c}:${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
  fi
  (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${c}⇣${VCS_STATUS_COMMITS_BEHIND}"
  (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
  (( VCS_STATUS_COMMITS_AHEAD  )) && res+="${c}⇡${VCS_STATUS_COMMITS_AHEAD}"
  (( VCS_STATUS_STASHES        )) && res+=" ${c}*${VCS_STATUS_STASHES}"
  [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${x}${VCS_STATUS_ACTION}"
  (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${x}~${VCS_STATUS_NUM_CONFLICTED}"
  (( VCS_STATUS_NUM_STAGED     )) && res+=" ${c}+${VCS_STATUS_NUM_STAGED}"
  (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${c}!${VCS_STATUS_NUM_UNSTAGED}"
  (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${c}?${VCS_STATUS_NUM_UNTRACKED}"
  (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${c}─"
  typeset -g _temas_git=$res
}
functions -M _temas_git_formato 2>/dev/null

() {
  emulate -L zsh -o extended_glob
  # começa do zero: o que estiver no teu ~/.p10k.zsh deixa de valer
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir                     # pasta
    vcs                     # git
    newline
    prompt_char             # ❯
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                  # ✔ ou ✘ do último comando
    command_execution_time  # quanto demorou (só a partir de 3 s)
    java_version            # Java (só dentro de projetos Java)
    node_version            # Node (só dentro de projetos Node)
    time                    # hora
    newline
  )

  # letra JetBrains Mono Nerd Font (vem na pasta fonte/)
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=

  # uma linha em branco entre um comando e o próximo, sem moldura
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  typeset -g POWERLEVEL9K_MULTILINE_{FIRST,NEWLINE,LAST}_PROMPT_{PREFIX,SUFFIX}=
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '
  typeset -g POWERLEVEL9K_MULTILINE_{FIRST,NEWLINE}_PROMPT_GAP_BACKGROUND=

  # setas entre os blocos
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=

  # ❯ sem bloco por trás
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=

  # pasta: encurta as pastas do meio, mostra inteira a raiz do projeto
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER='(.git|package.json|pom.xml|build.gradle|build.gradle.kts|project.godot|.shorten_folder_marker)'
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

  # git
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((_temas_git_formato()))+${_temas_git}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

  # ✔ / ✘
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_{OK,OK_PIPE}=true
  typeset -g POWERLEVEL9K_STATUS_{OK,OK_PIPE}_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_{ERROR,ERROR_SIGNAL,ERROR_PIPE}=true
  typeset -g POWERLEVEL9K_STATUS_{ERROR,ERROR_SIGNAL,ERROR_PIPE}_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false

  # tempo do comando
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  # Java e Node: só aparecem dentro de projetos dessas linguagens
  typeset -g POWERLEVEL9K_JAVA_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_JAVA_VERSION_FULL=false
  typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true

  # hora
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false

  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  # tem de ficar ligado: é assim que as cores mudam quando trocas de tema
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=false

  # cores do tema desta aba
  local estilo
  _temas_p10k_estilo; estilo=$REPLY
  _temas_p10k_tema
  typeset -g _temas_p10k_atual="$estilo|$REPLY"
  _temas_p10k_cores "$REPLY" "$estilo"

  (( ! $+functions[p10k] )) || p10k reload
}

# corre antes do Powerlevel10k em cada prompt
precmd_functions=(_temas_p10k_precmd ${precmd_functions:#_temas_p10k_precmd})

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
