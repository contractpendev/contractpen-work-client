pm2 delete contractpen-work-client
npm run compile
pm2 start src/EntryPoint.js --name "contractpen-work-client" -- subscribe localhost 3050
