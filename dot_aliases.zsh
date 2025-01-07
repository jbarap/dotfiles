# vanilla
alias cl="clear"
alias cls="cl; ls"
alias cppwd="pwd && pwd | xclip"
alias openapp="xdg-open"
alias watch="watch " # allow for watching aliases
alias xclip="xclip -selection c -rmlastnl"
alias aptgrep="sudo apt list --installed | grep -i"

# scripts
alias tcd="tmux-cd-session"
alias tnew="tmux-new-session"

# chezmoi
alias cnv="chezmoi edit"

# git
alias g="git"
alias wkt="git-fzf worktree list"
alias lz="lazygit"

# neovim
alias nv="nvim"
alias nvide="neovide --multigrid"
alias nvs="sudo -E -s nvim"

# python
alias ipy="ipython"
alias jl="jupyter-lab"
alias pt="poetry"
alias pipgrep="pip list | grep -i"
alias spy='sudo env "PATH=$PATH" py-spy'

# mamba
alias mm="micromamba"
alias conda="micromamba"

# viztracer
alias vtrace="viztracer --output_file ./profile.json --min_duration 25 --max_stack_depth 25 --"
alias vview="vizviewer"

# lazydocker
alias lzd="TERM=xterm-kitty lazydocker"

# kitty
alias icat="kitty +kitten icat"
alias s="kitty +kitten ssh"
alias kitty="env __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia kitty"

# docker
alias compose-run="docker compose run --rm"

# kubernetes
alias mkctl="microk8s kubectl"

# bat
alias cat="batcat"

# gcloud
alias gssh="gcloud compute ssh"
alias gscp="gcloud compute scp"
