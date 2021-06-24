#!/usr/bin/env bash
git clone --quiet -j64 --depth=1 https://github.com/fadlyas07/anykernel-3
export ARCH=arm64 && export SUBARCH=arm64 && check_date=$(TZ=Asia/Jakarta date)
my_id="1201257517" && channel_id="-1001360920692" && token="1501859780:AAFrTzcshDwfA2x6Q0lhotZT2M-CMeiBJ1U"
export KBUILD_BUILD_USER=fadlyas07 && export KBUILD_BUILD_HOST=greenforce-project && export KBUILD_BUILD_TIMESTAMP=$check_date
git clone --depth=1 https://github.com/kdrag0n/proton-clang
export PATH=$(pwd)/proton-clang/bin:$PATH
make -j$(nproc) -l$(nproc) ARCH=arm64 O=out ${1} && \
make -j$(nproc --all) -l$(nproc --all) ARCH=arm64 O=out AR=llvm-ar CC=clang \
NM=llvm-nm  OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump \
STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- LD=ld.lld 2>&1| tee build.log
if [[ ! -f $(pwd)/out/arch/arm64/boot/Image ]] ; then
    curl -F document=@$(pwd)/build.log "https://api.telegram.org/bot${token}/sendDocument" -F chat_id=${my_id}
    curl -s -X POST "https://api.telegram.org/bot${token}/sendMessage" -d chat_id=${my_id} -d text="Build failed! at branch $(git rev-parse --abbrev-ref HEAD)"
  exit 1 ;
fi
curl -F document=@$(pwd)/out/config "https://api.telegram.org/bot${token}/sendDocument" -F chat_id=${my_id}
curl -F document=@$(pwd)/build.log "https://api.telegram.org/bot${token}/sendDocument" -F chat_id=${my_id}
mv $(pwd)/out/arch/arm64/boot/Image $(pwd)/anykernel-3
cd $(pwd)/anykernel-3 && zip -r9q "${2}"-"${codename}"-"$(TZ=Asia/Jakarta date +'%d%m%y')".zip *
cd .. && curl -F "disable_web_page_preview=true" -F "parse_mode=html" -F document=@$(echo $(pwd)/anykernel-3/*.zip) "https://api.telegram.org/bot${token}/sendDocument" -F caption="
New updates for <b>${3}</b> based on Linux <b>$(cat $(pwd)/out/.config | grep Linux/arm64 | cut -d " " -f3)</b> at commit $(git log --pretty=format:"%h (\"%s\")" -1) | <b>SHA1:</b> $(sha1sum "$(echo $(pwd)/anykernel-3/*.zip)" | awk '{ print $1 }')" -F chat_id=${channel_id}
curl -F document=@$(pwd)/out/config "https://api.telegram.org/bot${token}/sendDocument" -F chat_id=${my_id}
