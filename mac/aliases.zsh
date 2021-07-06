# General
alias backup="~/.dotfiles/mac/backup.sh"
alias cat="bat -p"
alias gits="git submodule"
alias history="history 1"
alias ls="exa --git --group-directories-first -lgh"
alias rm="rm -v"
alias update="~/.dotfiles/mac/update_tools.sh"
alias uuid="uuidgen | tr '[:upper:]' '[:lower:]'"
alias vi="vi --clean"
alias vim=nvim

# Ad Hoc
alias ppldb="docker exec -it adhoc_co_postgres_1 psql -U postgres adhoc_co_development"

# QPP Auth
auth_db_var() {
    rg "^DB_$2=(.+)\$" --color never -N -r '$1' .$1.env | tr -d '[:space:]'
}
alias devdb='PGPASSWORD="$(auth_db_var dev PASSWORD)" /usr/local/opt/postgresql@12/bin/psql -h $(auth_db_var dev HOST) -U $(auth_db_var dev USERNAME) -p $(auth_db_var dev PORT)'
alias impdb='PGPASSWORD="$(auth_db_var imp PASSWORD)" /usr/local/opt/postgresql@12/bin/psql -h $(auth_db_var imp HOST) -U $(auth_db_var imp USERNAME) -p $(auth_db_var imp PORT)'
alias devpredb='PGPASSWORD="$(auth_db_var devpre PASSWORD)" psql -h $(auth_db_var devpre HOST) -U $(auth_db_var devpre USERNAME) -p $(auth_db_var devpre PORT)'
alias proddb='PGPASSWORD="$(auth_db_var prod PASSWORD)" psql -h $(auth_db_var prod HOST) -d $(auth_db_var prod DATABASE_NAME) -U $(auth_db_var prod USERNAME) -p $(auth_db_var prod PORT)'
