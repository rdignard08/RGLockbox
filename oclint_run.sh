source ~/.bash_profile
 
hash oclint &> /dev/null
if [ $? -eq 1 ]; then
    echo >&2 "oclint not found, analyzing stopped"
    exit 1
fi
 
rm -f ${TARGET_TEMP_DIR}/xcodebuild.log
 
cd ${SRCROOT}
 
xcodebuild -project RGLockbox.xcodeproj -scheme RGLockbox clean build | xcpretty -r json-compilation-database

cd ${TARGET_TEMP_DIR}
 
cp ${TARGET_TEMP_DIR}/compile_commands.json ${SRCROOT}/compile_commands.json
 
cd ${TARGET_TEMP_DIR}

oclint-json-compilation-database | sed 's/\(.*\.\m\{1,2\}:[0-9]*:[0-9]*:\)/\1 warning:/'

printf '\7\7' # notify user that the task is done
