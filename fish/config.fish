source /usr/share/cachyos-fish-config/cachyos-config.fish


alias tree 'eza --tree'
alias emacs 'emacs -nw'


status --is-interactive; and rbenv init - fish | source


# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
export PATH="$HOME/.local/bin:$PATH"
status --is-interactive; and source (rbenv init -|psub)
