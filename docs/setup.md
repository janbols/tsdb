# Setup timescaledb and grafana

Download data backup data from https://transfer-vinci-energies.netexplorer.pro/fdl/uGHmJIaNIPsofDCkSeo8I7LhfcDRkj and store it in ./backup.

    wget https://transfer-vinci-energies.netexplorer.pro/fdl/b4qZSBXZFz6DivVmk4wm2SHRgW1HEF -O backup/grafana.tar.gz
    wget https://transfer-vinci-energies.netexplorer.pro/fdl/J0ACLfRLqVujNFMoXSq9UB6oEk_hmN -O backup/tsdb.tar.gz

    docker-compose run --rm tsdb-restore
    docker-compose run --rm grafana-restore

    docker-compose up -d tsdb grafana
    docker-compose exec tsdb psql -U postgres
