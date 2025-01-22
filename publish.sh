DATA_BASE64="data:application/octet-stream;base64,$(base64 -i fake_build_output/GARS_1_0.data.unityweb)"
DATA_FRAMEWORK64="data:application/octet-stream;base64,$(base64 -i fake_build_output/GARS_1_0.framework.js.unityweb)"
DATA_LOADER64="data:application/octet-stream;base64,$(base64 -i fake_build_output/GARS_1_0.loader.js)"
DATA_WASM64="data:application/octet-stream;base64,$(base64 -i fake_build_output/GARS_1_0.wasm.unityweb)"
cat <<EOF > payload.json
{
  "game": {
    "name": "anon game",
    "assets": [
      {
        "filename": "GARS_1_0.data.unityweb",
        "data": "$DATA_BASE64"
      },
      {
        "filename": "GARS_1_0.framework.js.unityweb",
        "data": "$DATA_FRAMEWORK64"
      },
      {
        "filename": "GARS_1_0.loader.js",
        "data": "$DATA_LOADER64"
      },
      {
        "filename": "GARS_1_0.wasm.unityweb",
        "data": "$DATA_WASM64"
      }
    ]
  }
}
EOF


curl -X POST https://www.finalparsec.com/api/games \
-H "Content-Type: application/json" \
-d @payload.json
