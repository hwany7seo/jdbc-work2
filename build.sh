#!/bin/bash
#
#  Copyright 2008 Search Solution Corporation Copyright 2016 CUBRID Corporation
# 
#   Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance 
#   with the License. You may obtain a copy of the License at
# 
#       http://www.apache.org/licenses/LICENSE-2.0
# 
#   Unless required by applicable law or agreed to in writing, software distributed under the License is distributed 
#   on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License 
#   for the specific language governing permissions and limitations under the License.
# 
#

# Build and package script for CUBRID 
# Requirements 
# - Bash shell 
# - Build tool - ant

arg=$1
cur_dir=`pwd`
ant_file=$(which ant)

echo "[INFO] Checking build tools(ant)"
if [ $ant_file = "" ]; then
  echo "[ERROR] check need ANT(build tools)"
fi

if [ -z $arg ]; then
  echo "[INFO] Build Start"
elif [ $arg = "clean" ]; then
  echo "[INFO] Clean Build"
  $ant_file clean -buildfile $cur_dir/build.xml
  exit 0
fi

# check version
echo "[INFO] Checking VERSION"
if [ -f $cur_dir/VERSION ]; then
  version_file=VERSION
  version=$(cat $cur_dir/$version_file)
else 
  version="external"
fi

# check Git
echo "[INFO] Checking for Git"
which_git=$(which git)
[ $? -eq 0 ] && echo "[INFO] found $which_git" || echo "[CHECK] Git not found"
echo "[INFO] OK"

major_start_date='2021-03-01'
if [ -d $cur_dir/.git ]; then
  extra_version=$(cd $cur_dir && git rev-list --after $major_start_date --count HEAD | awk '{ printf "%04d", $1 }' 2> /dev/null)
else
  extra_version=0000
fi

echo "[INFO] VERSION = $version.$extra_version"

if [ ! -d $cur_dir/output ]; then
  mkdir -p $cur_dir/output
fi
cp -rfv $cur_dir/VERSION $cur_dir/output/CUBRID-JDBC-$version.$extra_version
$ant_file dist-cubrid -buildfile $cur_dir/build.xml -Dbasedir=. -Dversion=$version.$extra_version -Dsrc=./src