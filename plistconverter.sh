#!/bin/bash

HTML_FILES=$(find . -iname "*.html")

HEADER=$(cat <<-END
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>template_attachments</key>
  <array/>
  <key>template_html</key>
  <string>
END
)

FOOTER=$(cat <<-END
  <key>template_subject</key>
  <string></string>
</dict>
</plist>
END
)
for fullfile in $HTML_FILES; do
  path=$(dirname "$fullfile")
  parentdir="$(basename "$(dirname "$fullfile")")"
  filename=$(basename "$fullfile")
  extension="${filename##*.}"
  filename="${filename%.*}"
  newname="${parentdir}-${filename}"

  mkdir -p "output/${newname}"
  plist="output/${newname}/${newname}.plist"

  echo "$path $filename $extension $plist"
  html=$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g;' "$fullfile")
  #html=$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g' "$fullfile")

  printf "%s%s</string>\n" "$HEADER" "$html" > $plist
  printf "<key>template_name</key>\n<string>%s</string>\n%s" "${newname}" "$FOOTER" >> $plist
done
