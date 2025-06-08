# ~/.config/zsh/functions/systemd.zsh

# Funciones para systemd
if command -v systemctl &>/dev/null; then
    function start() {
        sudo systemctl start $1.service
    }
    
    function restart() {
        sudo systemctl restart $1.service
    }
    
    function stop() {
        sudo systemctl stop $1.service
    }
    
    function enable() {
        sudo systemctl enable $1.service
    }
    
    function status() {
        sudo systemctl status $1.service
    }
    
    function disable() {
        sudo systemctl disable $1.service
    }
fi
