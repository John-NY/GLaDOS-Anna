rm ~/glados.* ~/devel/GIT_MAIN/GLaDOS/glados.*
nohup festival --tts --server &
screen -t anna 1 ~/devel/GIT_MAIN/charliebot/server.sh
screen -t server 2 ~/devel/testbed/2011Nov05_relay/server/server 9001
screen -t glados 3 ~/devel/GIT_MAIN/GLaDOS/client_socket/server/server 9140
screen -t pianobar 4 pianobar
