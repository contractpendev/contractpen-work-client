npm run compile
pm2 start src/EntryPoint.js --name "contractpen_node_client" -- subscribe localhost 3050
