#!/bin/bash

# Thanks to adam for the script (Github username: adamspaini)

kernel_dir="${PWD}"
objdir="${kernel_dir}/out"
anykernel=$HOME/anykernel
builddir="${kernel_dir}/build"
ZIMAGE=$kernel_dir/out/arch/arm64/boot/Image
kernel_name="GoreKernel_vayu_"
zip_name="$kernel_name$(date +"%Y%m%d").zip"
CLANG_DIR=tc/clang
GCC64_DIR=tc/gcc64
GCC32_DIR=tc/gcc32

export CONFIG_FILE="vayu_user_defconfig"
export ARCH="arm64"
export KBUILD_BUILD_HOST=@adams4d13
export KBUILD_BUILD_USER=arch-linux

TOOLCHAIN=${1:-clang}  # Usa 'clang' por defecto, o 'gcc' si se pasa como argumento

# Color codes
NC='\033[0m'
RED='\033[0;31m'
LRD='\033[1;31m'
LGR='\033[1;32m'

# Establecer PATH de acuerdo al toolchain
if [[ "$TOOLCHAIN" == "clang" ]]; then
    export PATH="$CLANG_DIR/bin:$PATH"
    if ! [ -d "$CLANG_DIR" ]; then
        echo "Toolchain Clang no encontrado. Clonando en $CLANG_DIR..."
        git clone -q --depth=1 --single-branch https://gitlab.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-r547379.git -b 15.0 $CLANG_DIR || { echo "Fallo al clonar Clang. Abortando..."; exit 1; }
    fi
elif [[ "$TOOLCHAIN" == "gcc" ]]; then
    export PATH="$GCC64_DIR/bin:$GCC32_DIR/bin:$PATH"
    if ! [ -d "$GCC64_DIR" ]; then
        echo "Clonando GCC64..."
        git clone -q --depth=1 https://github.com/crdroidandroid/aarch64-linux-android-4.9.git $GCC64_DIR || exit 1
    fi
    if ! [ -d "$GCC32_DIR" ]; then
        echo "Clonando GCC32..."
        git clone -q --depth=1 https://github.com/crdroidandroid/arm-linux-androideabi-4.9.git $GCC32_DIR || exit 1
    fi
else
    echo "Toolchain inválido: $TOOLCHAIN. Usa 'clang' o 'gcc'."
    exit 1
fi

make_defconfig()
{
    START=$(date +"%s")
    echo -e ${LGR} "########### Generating Defconfig ############${NC}"
    make -s ARCH=${ARCH} O=${objdir} ${CONFIG_FILE} -j$(nproc --all)
}

compile() {

    cd ${kernel_dir}
    echo -e ${LGR} "######### Compiling kernel #########${NC}"
    make -j$(nproc --all) \
        O=${objdir} \
        ARCH=arm64 \
        SUBARCH=arm64 \
        CLANG_TRIPLE=aarch64-linux-gnu- \
        CROSS_COMPILE=aarch64-linux-gnu- \
        CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
        CROSS_COMPILE_COMPAT=arm-linux-gnueabi- \
        LD=ld.lld \
        AR=llvm-ar \
        NM=llvm-nm \
        STRIP=llvm-strip \
        OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        READELF=llvm-readelf \
        HOSTCC=clang \
        HOSTCXX=clang++ \
        HOSTAR=llvm-ar \
        HOSTLD=ld.lld \
        LLVM=1 LLVM_IAS=1 \
        CC="ccache clang" \
        "$@"
    else
        make -j$(nproc --all) \
        O=${objdir} \
        ARCH=arm64 \
        SUBARCH=arm64 \
        CROSS_COMPILE=aarch64-linux-android- \
        CROSS_COMPILE_ARM32=arm-linux-androideabi- \
        "$@"
    fi
}

completion() {
    cd ${objdir}
    COMPILED_IMAGE=arch/arm64/boot/Image
    COMPILED_DTBO=arch/arm64/boot/dtbo.img
    if [[ -f ${COMPILED_IMAGE} && -f ${COMPILED_DTBO} ]]; then
        git clone -q https://github.com/GXC2356/AnyKernel3.git -b master $anykernel
        mv -f $ZIMAGE ${COMPILED_DTBO} $anykernel
        cd $anykernel
        zip -r AnyKernel.zip *
        mv AnyKernel.zip $zip_name
        mv $anykernel/$zip_name $HOME/$zip_name
        rm -rf $anykernel
        echo -e ${LGR}"#### Build completado con éxito ####"${NC}
        exit 0
    else
        echo -e ${RED}"#### Error en la compilación ####"${NC}
        exit 1
    fi
}

make_defconfig
compile | tee ${objdir}/log.txt
completion
cd ${kernel_dir}