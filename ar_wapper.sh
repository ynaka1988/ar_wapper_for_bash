#!/bin/bash

CROSS_PREFIX="nios2-elf-"

AR="${CROSS_PREFIX}ar"


# 使用許可のある.oのリスト
# 手書きか、readlineか、とにかく作る
WHITE_LIST=(
	"lib_a-scanf.o"
	"lib_a-ldiv.o"
)

function ExtractObj()
{
	local lib_name="${1}"
	local obj="${2}"

	"${AR}" -x "${lib_name}" "${obj}"

	return ${?}
}


function AddObj()
{
	local lib_name="${1}"
	local obj="${2}"

	# 速度優先ならrではなくqだが、GNU ar の実装ではrもqも同義
	${AR} -crv "${lib_name}" "${obj}"

	return ${?}
}

function CpObjToNewLib
{
	local src_lib="${1}"
	local dst_lib="${2}"

	local ret=0
	for obj in "${WHITE_LIST[@]}"; do
		ExtractObj "${src_lib}" "${obj}" && AddObj "${dst_lib}" "${obj}"
		ret=${?}
		rm "${obj}"
	done

	return ${ret}
}


function main()
{
	local ret=0

	local target_lib_name="libc.a"
	local new_lib_name="newlibc.a"

	# パス区切り文字の関係？でarの引数にライブラリのフルパスを指定できない
	# カレントディレクトリを変更して回避
	local nios2eds_dir="/cygdrive/c/altera/13.1/nios2eds/"
	local lib_dir="${nios2eds_dir}/bin/gnu/h-i686-mingw32/nios2-elf/lib/"
	pushd "${lib_dir}" > /dev/null

	CpObjToNewLib "${target_lib_name}" "${new_lib_name}"
	ret=${?}

	popd > /dev/null

	return ${ret}
}


main ${@}

