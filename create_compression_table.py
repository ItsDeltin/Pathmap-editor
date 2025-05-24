import json

segments: list[str] = []
s = 0
offset = 32
length = 4096
split = 128
# Compression table will be stored in workshop strings.
# Do not use " in the compression table so that we do not need
# to worry about escaping them in the pathmap exporter.
banned_characters = ['"', '{', '}', '\\']

for i in range(length):
    if len(segments) == 0 or len(segments[-1]) >= split:
        segments.append('')

    while chr(i + offset) in banned_characters:
        offset += 1

    segments[-1] += chr(i + offset)

with open('compression-table.json', 'w', encoding='utf8') as json_file:
    json.dump(segments, json_file, ensure_ascii=False, indent=2)
