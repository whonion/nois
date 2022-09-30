#apt update && apt upgrade -y
#apt install curl build-essential git wget jq make gcc tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y
ver="1.19" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version && \
git clone https://github.com/noislabs/full-node && cd full-node/full-node/
./setup.sh
mv out/noisd $HOME/go/bin/
noisd version --long | head && \
#gotta out
# version: 0.28.0
# commit: 288609255ad92dfe5c54eae572fe7d6010e712eb
noisd init whonion --chain-id nois-testnet-002 && \
wget -O $HOME/.noisd/config/genesis.json "https://raw.githubusercontent.com/noislabs/testnets/main/nois-testnet-002/genesis.json" && \
cd && cat .noisd/data/priv_validator_state.json && \
noisd config chain-id nois-testnet-002 && \
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025unois\"/;" ~/.noisd/config/app.toml && \
# add seeds/bpeers/peers в config.toml && \
external_address=$(wget -qO- eth0.me) && \
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:26656\"/" $HOME/.noisd/config/config.toml && \
peers="a1222dfb8641e0cb55615b75e0122d5695be1f35@node-0.noislabs.com:26656,2df500525826199afc25665ee7cc45ceb86d68d7@node-1.noislabs.com:26656,61be6aa87471196757ea0f7b1d7897e97b4e09c2@node-2.noislabs.com:26656,cf16671c00eec9a9a047a5c6aa8510cb681b64b8@node-3.noislabs.com:26656" && \
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.noisd/config/config.toml && \
#bpeers="" && \
#sed -i.bak -e "s/^bootstrap-peers *=.*/bootstrap-peers = \"$bpeers\"/" $HOME/.noisd/config/config.toml && \
seeds="" && \
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.noisd/config/config.toml && \
# if necessary, increase the number of incoming and outgoing peers for the connection, except for persistent peers in config.toml
# can help with a node crash, but increases the load
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 50/g' $HOME/.noisd/config/config.toml && \
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 50/g' $HOME/.noisd/config/config.toml && \
# Set up filtering of "bad" peers
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.noisd/config/config.toml && \
# set up custom prunning(optional)
pruning="custom" && \
pruning_keep_recent="100" && \
pruning_keep_every="0" && \
pruning_interval="50" && \
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.noisd/config/app.toml && \
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.noisd/config/app.toml && \
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.noisd/config/app.toml && \
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.noisd/config/app.toml && \
#disable indexer(optional)
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.noisd/config/config.toml && \
# Default "snapshot-interval=1500"
snapshot_interval=1000 && \
sed -i.bak -e "s/^snapshot-interval *=.*/snapshot-interval = \"$snapshot_interval\"/" ~/.noisd/config/app.toml && \
#change ports(optional 4 second node)
# config.toml
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:36658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:36657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:6061\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:36656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":36660\"%" $HOME/.noisd/config/config.toml && \
# app.toml
sed -i.bak -e "s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:9190\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:9191\"%" $HOME/.noisd/config/app.toml && \
# client.toml
sed -i.bak -e "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:36657\"%" $HOME/.noisd/config/client.toml && \
external_address=$(wget -qO- eth0.me) && \
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:36656\"/" $HOME/.noisd/config/config.toml && \
# CREATE DEAMON
sudo tee /etc/systemd/system/noisd.service > /dev/null <<EOF
[Unit]
Description=noisd
After=network-online.target

[Service]
User=$USER
ExecStart=$(which noisd) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF && \
# Add autorun and restart services
systemctl daemon-reload && \
systemctl enable noisd && \
systemctl restart noisd && journalctl -u noisd -f -o cat
