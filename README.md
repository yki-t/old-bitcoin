# old-bitcoin

```bash
./download.sh
cd bitcoin
git apply ../patch
cd ../

docker build -t btc . && docker run -v ./bitcoin:/tmp/bitcoin -it btc bash
```

```bash
cd src
make -f makefile.unix
```
