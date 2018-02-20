#!/bin/bash

# Find all the html templates in the templates folder
HTML_FILES=$(find ./templates -iname "*.html")

# Airmail has a pretty uniform header and footer
# NOTE this opens a <string> tag that it doesn't close until the printf statement later
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
  # The template names don't include the theme by default we need them so get parentdir name
  parentdir="$(basename "$(dirname "$fullfile")")"
  filenameWithExt=$(basename "$fullfile")
  filename="${filenameWithExt%.*}"
  newname="${parentdir}-${filename}"

  # Airmail likes each plist to be in a folder of the same name
  mkdir -p "output/${newname}"
  plist="output/${newname}/${newname}.plist"

  # Lets see what we are doing
  echo "$filename >> $plist"

  # Parse the html for the plist file so far it seems only &, <, and > need to be escaped
  html=$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g;' "$fullfile")

  # Other escape sequences for reference
  #html=$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g' "$fullfile")

  # Spit the whole thing out to a new file
  printf "%s%s</string>\n" "$HEADER" "$html" > $plist
  printf "<key>template_name</key>\n<string>%s</string>\n%s" "${newname}" "$FOOTER" >> $plist
done
