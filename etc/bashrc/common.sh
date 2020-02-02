export PATH=$PATH:~/bin:/srv/.npm-packages/bin
export TERM=xterm

# Use only if the shell is opened via SSH
if [ -n "$SSH_TTY" ]; then
    GREEN="\e[32m"
    YELLOW="\e[93m"
    RED="\e[91m"
    NC='\033[0m'

    echo ""
    echo -e " >> ${GREEN}Before you start, check our documentation at ${YELLOW}https://docs.rosti.cz${NC}"
    echo -e " >> ${GREEN}and if you encounter a problem let us know at ${YELLOW}podpora@rosti.cz${GREEN}.${NC}"
    echo ""

    if [ ! -e /srv/app ]; then
        echo ""
        echo -e "${RED}WARNING: ${YELLOW}No technology (Python/Node/PHP/..) has been selected yet, please run command:"
        echo ""
        echo -e "${NC}    rosti"
        echo ""
        echo -e "${RED}to fix it."
        echo ""
    fi

    if [ -e /srv/venv ]; then
        . /srv/venv/bin/activate
    fi
fi
