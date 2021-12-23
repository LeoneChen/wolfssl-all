SGX_SDK ?= /opt/intel/sgxsdk
SGX_MODE ?= HW
SGX_ARCH ?= x64
SGX_WOLFSSL_LIB ?= ../wolfssl/IDE/LINUX-SGX
SGX_DEBUG ?= 1
WOLFSSL_ROOT ?= ../wolfssl
HAVE_WOLFSSL_TEST ?= 1
HAVE_WOLFSSL_BENCHMARK ?= 1

ifndef WOLFSSL_ROOT
$(error WOLFSSL_ROOT is not set. Please set to root wolfssl directory)
endif

export

######## SGXSanRT Settings ########

# Customized. Set by user.
SGXSanPath := $(abspath ../../../SGXSan)
CwdPath := $(abspath .)

SGXSan_Pass := $(SGXSanPath)/SGXSanPass/build/libSGXSanPass.so

SGXSanRTApp_Cpp_Files := $(wildcard $(SGXSanPath)/SGXSanRT/SGXSanRTApp/*.cpp)
SGXSanRTEnclave_Cpp_Files := $(wildcard $(SGXSanPath)/SGXSanRT/SGXSanRTEnclave/*.cpp)

LibSGXSanRTApp := $(SGXSanPath)/SGXSanRT/libSGXSanRTApp.a
LibSGXSanRTEnclave := $(SGXSanPath)/SGXSanRT/libSGXSanRTEnclave.a

SGXSanRTApp_Link_Flags := -L$(SGXSanPath)/SGXSanRT -lSGXSanRTApp
# use whole-archive in order to let linker will not ignore ctor(prefixed by "__attribute__((constructor))") symbol
SGXSanRTEnclave_Link_Flags := -L$(SGXSanPath)/SGXSanRT -Wl,--whole-archive -lSGXSanRTEnclave -Wl,--no-whole-archive

Enclave_Config_File := trusted/Wolfssl_Enclave.config.xml
Signed_Enclave_Name := Wolfssl_Enclave.signed.so

######## End of SGXSanRT Settings ########

all: $(SGXSan_Pass) $(LibSGXSanRTEnclave)
	$(MAKE) -ef sgx_u.mk all
	$(MAKE) -ef sgx_t.mk all

######## SGXSan Objects ########

$(SGXSanPath)/SGXSanManifest/SGXSanManifest.h: $(Enclave_Config_File)
	@cd $(SGXSanPath)/SGXSanManifest/ && python3 SyncHeapSize.py $(CwdPath)/$(Enclave_Config_File) || { echo "SyncHeapSize Failed" && exit 1;}

$(SGXSan_Pass): $(SGXSanPath)/SGXSanPass/SGXSanPass.cpp $(SGXSanPath)/SGXSanManifest/SGXSanManifest.h
	@echo "===============Make SGXSanPass=============="
	@cd $(SGXSanPath)/SGXSanPass && ./build.sh
	@echo "==========Finish making SGXSanPass=========="

# if file in subdir changed, then call sub-make
$(LibSGXSanRTApp): $(SGXSanRTApp_Cpp_Files) $(SGXSanRTEnclave_Cpp_Files) $(SGXSanPath)/SGXSanManifest/SGXSanManifest.h
	@$(MAKE) -C $(SGXSanPath)/SGXSanRT Enclave_File_Name=$(Signed_Enclave_Name) SGX_SDK=$(SGX_SDK) SGX_MODE=$(SGX_MODE) SGX_ARCH=$(SGX_ARCH) SGX_DEBUG=$(SGX_DEBUG) SGX_PRERELEASE=$(SGX_PRERELEASE) SGXSanPath=$(SGXSanPath)

$(LibSGXSanRTEnclave): $(LibSGXSanRTApp)

######## SGXSan End ########

clean:
	$(MAKE) -ef sgx_u.mk clean
	$(MAKE) -ef sgx_t.mk clean
	@rm -rf $(SGXSanPath)/SGXSanPass/build/*
	@$(MAKE) -C $(SGXSanPath)/SGXSanRT clean
	@rm -rf sgxsan_data*

