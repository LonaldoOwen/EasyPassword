#!/usr/bin/env bash
# 按照Google的Shell风格指南编码
# 设备名称
devices=("platform=iOS Simulator,name=iPhone X,OS=11.3"
"platform=iOS Simulator,name=iPhone X 2,OS=11.3")

# scheme
test_scheme_name='EasyPasswordUITests'
for (( i=0; i<${#devices[@]}; i++ )); do
  devices[$i]="xcodebuild
  -scheme $test_scheme_name
  -destination '"${devices[$i]}"'"
  echo ${devices[$i]}
done

#
i=0
path_to_test_classes='EasyPasswordUITests'
for entry in "$path_to_test_classes"/*Test.swift; do
  # 当i=2时退出循环
  if (( i == ${#devices[@]} )); then
    i=0
  fi
  # LoginTest.swift（获取LoginTest.swift字符串）
  name="${entry##*/}"
  echo ${name}
  # LoginTest（获取LoginTest字符串）
  name="${name%.*}"
  echo ${name}
  # 拼接字符串
  devices[$i]=${devices[$i]}"
  -only-testing:$test_scheme_name/$name"
  ((i++))
  echo ${devices[$i]}
done

#
cmd=''
for (( i=0; i<${#devices[@]}; i++ )); do
  cmd=${cmd}${devices[$i]}" test & "
done
echo ${cmd}
#eval ${cmd}
