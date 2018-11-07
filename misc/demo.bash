# asciinema rec --overwrite tmp/demo.case
# bash demo.bash

type_and_run () {
  printf '\033[01;37m@app $\033[0m '
  for ((i=0; i<${#1}; i++)); do echo "after `jot -r 1  20 60`" | tclsh; printf "${1:$i:1}"; done;
  echo;
  $1;
  echo;
}

info () {
  echo $1 | lolcat
}

info 'DEMO > Clear all assets'
type_and_run 'bundle exec lux_assets clear'
info 'DEMO > Show config'
type_and_run 'cat config/assets.rb'
sleep 2
info 'DEMO > Show all assets/fils in config collection'
type_and_run 'bundle exec lux_assets show'
sleep 1
info 'DEMO > Production compile all assets'
type_and_run 'bundle exec lux_assets compile'
info 'DEMO > Live monitor, error trigger, and valid compile'
sleep 2
type_and_run 'bundle exec lux_assets monitor'

