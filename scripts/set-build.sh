#!/bin/bash

git=$(sh /etc/profile; which git)
gitCommitCount=$("$git" rev-list HEAD --count)
gitCommit="$(git rev-list $(git rev-parse --abbrev-ref HEAD) | head -n 1 | cut -c1-6)"
gitCommitDecimal="$((16#$gitCommit))"

echo "Setting building version to $gitCommitCount.$gitCommitDecimal for commit $gitCommit"

#git_release_version=$("$git" describe --tags --always --abbrev=0)

target_plist="$TARGET_BUILD_DIR/$INFOPLIST_PATH"
dsym_plist="$DWARF_DSYM_FOLDER_PATH/$DWARF_DSYM_FILE_NAME/Contents/Info.plist"

for plist in "$target_plist" "$dsym_plist"; do
  if [ -f "$plist" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $gitCommitCount.$gitCommitDecimal" "$plist"
    #/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${git_release_version#*v}" "$plist"
  fi
done
