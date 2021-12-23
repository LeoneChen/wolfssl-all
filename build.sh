if [ ! -f v5.0.0-stable.tar.gz ]; then
    wget https://github.com/wolfSSL/wolfssl/archive/refs/tags/v5.0.0-stable.tar.gz
fi
tar -xzf v5.0.0-stable.tar.gz
mv wolfssl-5.0.0-stable/ wolfssl/
cd wolfssl && ./autogen.sh && ./configure && ./config.status
cd IDE/LINUX-SGX
./clean.sh
make -f sgx_t_static.mk CFLAGS=-DDEBUG_WOLFSSL HAVE_WOLFSSL_BENCHMARK=1 HAVE_WOLFSSL_TEST=1 HAVE_WOLFSSL_SP=1