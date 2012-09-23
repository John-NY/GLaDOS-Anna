# rm ~/glados.* ~/devel/GIT_MAIN/GLaDOS/glados.*
nohup festival --tts --server &
sleep 5
screen -t anna 1 ~/devel/GIT_MAIN/charliebot/server.sh
sleep 5
screen -t server 2 ~/devel/GIT_MAIN/GLaDOS/client_socket/variable_server/server 9001 ~/devel/GIT_MAIN/GLaDOS/XBee_ctrl.pl
sleep 5
heyu start
sleep 5
screen -t glados 3 ~/devel/GIT_MAIN/GLaDOS/client_socket/variable_server/server 9140 /usr/bin/GLaDOS
sleep 5
heyu engine
sleep 5
screen -t pianobar 4 pianobar
sleep 5
screen -t says 5 ~/devel/GIT_MAIN/GLaDOS/client_socket/variable_server/server 9002 /usr/bin/says
